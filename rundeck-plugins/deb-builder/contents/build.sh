#!/bin/bash -xe

S3_BASE=rundeck-playground/consul/

cd $(mktemp -d)

_pkgdir="pkg"

NAME=consul
BIN_NAME=${BIN_NAME-$NAME}
VERSION="1.2.3"
URL="https://releases.hashicorp.com/consul/${VERSION}/consul_${VERSION}_linux_amd64.zip"

mkdir -p "$_pkgdir"

echo "INFO - Downloading $URL"
curl -sOL "$URL"

echo "INFO - Packaging $NAME version $VERSION"
unzip $(basename "$URL")
touch $BIN_NAME
mkdir -p "${_pkgdir}/usr/bin"
install "$BIN_NAME" "${_pkgdir}/usr/bin"
cd ${_pkgdir}
DEB_FILE=$(fpm -s dir -t deb --name "$NAME" --version "$VERSION" . | ruby -e 'puts eval(STDIN.read)[:path]')

echo "INFO - Uploading $DEB_FILE to $S3_URL"
S3_URL="s3://${S3_BASE%%/*}/${DEB_FILE}"
export AWS_ACCESS_KEY_ID=$1
set +x
export AWS_SECRET_ACCESS_KEY=$2
set -x
aws s3 cp --quiet "$DEB_FILE" "$S3_URL"

echo "INFO - Generating presigned url for $S3_URL"
echo -n "RUNDECK:DATA:DOWNLOAD_URL = "
aws s3 presign "$S3_URL"
echo "RUNDECK:DATA:DEB_FILE = $DEB_FILE"
