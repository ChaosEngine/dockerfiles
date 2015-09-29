#!/bin/bash
#
#docker run -it -v /home/container/dotnet-coreclr:/dotnet-coreclr:ro ubuntu:14.04 bash

apt-get -y install wget curl;

echo "deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.6 main" | tee /etc/apt/sources.list.d/llvm.list \
	&& wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | apt-key add - \
	&& apt-get update

apt-get -y install cmake llvm-3.5 clang-3.5 lldb-3.6 lldb-3.6-dev libunwind8 libunwind8-dev gettext git

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
	&& echo "deb http://download.mono-project.com/repo/debian wheezy main" | tee /etc/apt/sources.list.d/mono-xamarin.list \
	&& echo "deb http://jenkins.mono-project.com/repo/debian sid main" | sudo tee /etc/apt/sources.list.d/mono-jenkins.list \
	&& apt-get update \
	&& apt-get -y install mono-devel mono-snapshot-latest referenceassemblies-pcl libcurl4-openssl-dev libssl-dev libicu-dev

mkdir -p ~/coreclr-demo/packages && mkdir -p ~/coreclr-demo/runtime && mkdir -p ~/git/ \
	&& cd ~/coreclr-demo/packages && curl -L -O https://nuget.org/nuget.exe

cd ~/git/ \
	&& git clone https://github.com/dotnet/coreclr.git \
	&& git clone https://github.com/dotnet/corefx.git

cd ~/git/coreclr \
	&& ./build.sh \
	&& cp bin/Product/Linux.x64.Debug/corerun ~/coreclr-demo/runtime \
	&& cp bin/Product/Linux.x64.Debug/libcoreclr.so ~/coreclr-demo/runtime

cd ~/git/corefx \
	&& mozroots --import --sync \
	&& source mono-snapshot mono \
	&& ./build.sh \
	&& cp bin/Linux.x64.Debug/Native/*.so ~/coreclr-demo/runtime
	
cp /dotnet-coreclr/* ~/coreclr-demo/runtime/ && ls ~/coreclr-demo/runtime/ \
	&& cd ~/coreclr-demo/packages

cat > packages.config << EOF
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="System.Console" version="4.0.0-beta-22703" />
  <package id="System.Diagnostics.Contracts" version="4.0.0-beta-22703" />
  <package id="System.Diagnostics.Debug" version="4.0.10-beta-22703" />
  <package id="System.Diagnostics.Tools" version="4.0.0-beta-22703" />
  <package id="System.Globalization" version="4.0.10-beta-22703" />
  <package id="System.IO" version="4.0.10-beta-22703" />
  <package id="System.IO.FileSystem.Primitives" version="4.0.0-beta-22703" />
  <package id="System.Reflection" version="4.0.10-beta-22703" />
  <package id="System.Resources.ResourceManager" version="4.0.0-beta-22703" />
  <package id="System.Runtime" version="4.0.20-beta-22703" />
  <package id="System.Runtime.Extensions" version="4.0.10-beta-22703" />
  <package id="System.Runtime.Handles" version="4.0.0-beta-22703" />
  <package id="System.Runtime.InteropServices" version="4.0.20-beta-22703" />
  <package id="System.Text.Encoding" version="4.0.10-beta-22703" />
  <package id="System.Text.Encoding.Extensions" version="4.0.10-beta-22703" />
  <package id="System.Threading" version="4.0.10-beta-22703" />
  <package id="System.Threading.Tasks" version="4.0.10-beta-22703" />
</packages>
EOF

mono nuget.exe restore -Source https://www.myget.org/F/dotnet-corefx/ -PackagesDirectory . \
	&& find . -wholename '*/aspnetcore50/*.dll' -exec cp -n {} ~/coreclr-demo/runtime \;
	
cd ~/coreclr-demo/runtime \
	&& curl -O https://raw.githubusercontent.com/dotnet/corefxlab/master/demos/CoreClrConsoleApplications/HelloWorld/HelloWorld.cs \
	&& mcs /nostdlib /noconfig /r:../packages/System.Console.4.0.0-beta-22703/lib/contract/System.Console.dll /r:../packages/System.Runtime.4.0.20-beta-22703/lib/contract/System.Runtime.dll HelloWorld.cs
	
#cp /root/git/coreclr/bin/obj/Linux.x64.Debug/src/pal/src/libcoreclrpal.a ~/coreclr-demo/runtime


./corerun HelloWorld.exe linux
