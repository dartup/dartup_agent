#!/bin/bash
cd ~
git clone https://github.com/dartup/dartup_agent.git agent
export POSTGRES_URI=[databasestring]
cd agent
pub get
dart bin/main.dart