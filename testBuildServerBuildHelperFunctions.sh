#!/bin/sh

my_dir="$(dirname "$0")"

source "$my_dir/BuildServerBuildHelperFunctions.sh"
validate_thatTheEmbeddedProfileHasTheSameAppGroupAsTheEntitlement /Users/user/Desktop/3.0.1811/join.me.ipa
validate_thatApplicationIdentifiersAreTheCorrectOnes /Users/user/Desktop/3.0.1811/join.me.ipa
