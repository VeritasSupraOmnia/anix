# run ./build.sh to make all
# give first argument "install" to install
# if you don't have parallel installed, delete that command and uncomment the while loop.
j=16
linexec="parallel -j$j {}" # "while read -r a ; do $a ; done"
maketools(){
# first make all custom tools needed to build the rest
 nasm ./PERM.a -o ./BIN/PERM 
 chmod +x ./BIN/PERM
}
preproc(){ # do vectal preproc for all files and 
 <CT.a rcom|vectal >CT.ppa
 <LS.a rcom|vectal >LS.ppa
 <PS.a rcom|vectal >PS.ppa
}
make (){
 pteststr=" 0:1=,t 0:0=,-Dperftest "
 # LS building
 str="$(./BIN/PERM "nasm @0:0 @1:0 @2:0 @3:0 @4:0 ./LS.ppa -o ./BIN/@1:1@2:1LS@3:1@4:1@0:1" 1:1=,f,d,a 2:1=,h,m 3:1=,c,x 4:1=,l,p,r  1:0=,-Dfilesonly,-Ddirsonly,-Dalmostdirs  2:0=,-Dhiddenonly,-Dmonstonly  3:0=,-Ddocontains,-Ddoextension  4:0=,-Ddolocal,-Ddopath,-Ddoroot $pteststr)"
 # PND building
 str="$(echo "$str" && echo "$(./BIN/PERM "nasm @0:0 @1:0 ./PND.a -o ./BIN/@1:1PND@0:1" 1:1=,a,f,h,d,x  1:0=-Datstart,-Datend,-Datfilename,-Dposthidden,-Datdot,-Datextension $pteststr)")"
 # CT
 str="$(echo "$str" && echo "$(./BIN/PERM "nasm @0:0 @1:0 @2:0 @3:0 ./CT.ppa -o ./BIN/@1:1CT@3:1@2:1@0:1" $pteststr 1:0=-Dandcombine,-Dandcombine,-Dorcombine,-Dxorcombine 1:1=,a,o,x  2:0=,-Dcaseinsensitive 2:1=,i "3:0=,-Dsearchstart" 3:1=,s )")"
 # PS
 str="$(echo "$str" && echo "$(./BIN/PERM "nasm @0:0 ./PS.ppa -o ./BIN/PS@0:1" $pteststr)")"
 str="$(echo "$str" && echo "$(./BIN/PERM "nasm @0:0 ./SRT.a -o ./BIN/SRT@0:1" $pteststr)")"
 str="$(echo "$str" && echo "$(./BIN/PERM "nasm @0:0 ./TNS.a -o ./BIN/TNS@0:1" $pteststr)")"
 str="$(echo "$str" && echo "$(./BIN/PERM "nasm @0:0 ./PERM.a -o ./BIN/PERM@0:1" $pteststr)")"
 str="$(echo "$str" && echo "$(./BIN/PERM "nasm @0:0 ./LS.ppa -o ./BIN/LS@0:1" $pteststr)")"
 str="$(echo "$str" && echo "$(./BIN/PERM "nasm @0:0 ./RM.a -o ./BIN/RM@0:1" $pteststr)")"
 echo "$str"|parallel -j$j {} 
 nasm MRG.a -o ./BIN/MRG
 chmod +x ./BIN/* # ensure all binaries get set as executable
}
install(){
 sudo cp $(./BIN/fmLSp ./BIN/) /usr/bin/ # "p" prints the path before each list item
}
mkdir -p ./BIN
rm -rf ./BIN/*
rm *.ppa
preproc
maketools
make
$1
