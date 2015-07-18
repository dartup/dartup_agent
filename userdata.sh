#!/bin/bash
cd ~
yum -y update
yum -y install git nginx
wget https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip
unzip dartsdk-linux-x64-release.zip
chmod -R a+rX dart-sdk
mv dart-sdk /opt/dart
echo "export PATH=$PATH:/opt/dart/bin" > /etc/profile.d/dart.sh
source /etc/profile
git clone https://github.com/dartup/dartup_agent.git agent
export POSTGRES_URI=[databasestring]
cd agent
pub get
dart bin/main.dart