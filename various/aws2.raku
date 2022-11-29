use JSON::Fast;
#needs $HOME/.aws/credentials

my $et = time;    #for unique names

class VPC {
    has $.id;

    method TWEAK {
        qqx`aws ec2 describe-vpcs --filters Name=is-default,Values=true` andthen
        $!id := .&from-json<Vpcs>[0]<VpcId> 
    }
}

class KeyPair {
    has $.dir = '.';
    has $.name;

    method names-from-aws {
        qqx`aws ec2 describe-key-pairs` andthen
        .&from-json<KeyPairs>.map: *<KeyName>
    }

    method names-from-dir {
        dir($!dir).grep(/pem/).map({S/.pem//})
    }

    method create-key-pair {
        qqx`aws ec2 create-key-pair --key-name $!name --query 'KeyMaterial' --output text > $!name.pem`;
        qqx`chmod 400 $!name.pem`
    }

    method TWEAK {
        for self.names-from-dir -> $dn {
            if $dn ∈ self.names-from-aws.Set {   # is there a matching .pem file in dir 
                $!name := $dn;
                last
            }
        }

        if ! $!name {                           # otherwise, make a new one
            $!name := "MyKeyPair$et";
            self.create-key-pair
        }
    }
}

class SecurityGroup {
    has $.sg-id;
}

class Instance {
    has $.instance-id;
    has $.image-id = 'ami-0f540e9f488cfa27d';   #x86 for now
    has $.instance-type = 't2.micro';
    has $.public-dns-name;
    has $.public-ip-address;

}

class Session {
    has $.vpc;
    has $.key-pair;
    has $.sg;
    has $.client-ip;
}

my $vpc = VPC.new andthen say .id;
my $key-pair = KeyPair.new andthen say .name;
die;

#`[
#create-security-group
qqx`aws ec2 create-security-group --group-name my-sg$et --description "My security group" --vpc-id $vpc-id` andthen
say my $sg-id = .&from-json<GroupId>;

qqx`curl https://checkip.amazonaws.com` andthen
say my $client-ip = .chomp;
my $client-cidr = "$client-ip/0";

qqx`aws ec2 authorize-security-group-ingress --group-id $sg-id --protocol tcp --port 22 --cidr $client-cidr`;
qqx`aws ec2 describe-security-groups --group-ids $sg-id` andthen
say .&from-json;

my $image-id = 'ami-0f540e9f488cfa27d';
my $instance-type = 't2.micro';
qqx`aws ec2 run-instances --image-id $image-id --count 1 --instance-type $instance-type --key-name $key-name --security-group-ids $sg-id` andthen
say my $instance-id = .&from-json<Instances>[0]<InstanceId>;

qqx`aws ec2 describe-instances --instance-ids $instance-id` andthen
say my $describe-instances = .&from-json;

say my $public-dns-name   = $describe-instances<Reservations>[0]<Instances>[0]<PublicDnsName>;
say my $public-ip-address = $describe-instances<Reservations>[0]<Instances>[0]<PublicIpAddress>;

sleep(5);
say qq`ssh -o "StrictHostKeyChecking no" -i "MyKeyPair.pem" ubuntu@$public-dns-name`; 
#]
