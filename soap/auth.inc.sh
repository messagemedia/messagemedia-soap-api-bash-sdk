#
# Copyright 2014 MessageMedia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# Include file to be used by MessageMedia SOAP API example scripts.
#

# If not specified already (eg via environment variables), prompt the user for
# the MessageMedia SOAP API credentials to use.
if [ -z "$MESSAGEMEDIA_USERID" ]; then
    read -p "MessageMedia SOAP API userId: " -r MESSAGEMEDIA_USERID
    unset MESSAGEMEDIA_PASSWORD
fi
if [ -z "$MESSAGEMEDIA_PASSWORD" ]; then
    read -p "MessageMedia SOAP API password: " -r -s MESSAGEMEDIA_PASSWORD
    echo 2>&1
fi
