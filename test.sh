#!/bin/bash

try() {
    expected="$1"
    input="$2"
    ./kcc "$input" > tmp.s
    gcc -o tmp tmp.s tmp-test.o
    ./tmp
    actual="$?"

    if [ "$actual" = "$expected" ]; then
        echo "$input => $actual"
    else
        echo "$input => $expected expected, but got $actual"
        exit 1
    fi
}


cat <<EOF | gcc -xc -c -o tmp-test.o -
int global_arr[1] = {5};
int plus(int a, int b) {
    return a + b;
}
EOF

try 0 "int main(){}"
try 0 "int main(){return 0;}"
try 42 "int main(){return 42;}"
try 18 "int main(){return 5+20-4-3;}"
try 41 " int main( ) { return 12 + 34 - 5 ; } "
try 41 " int main( ) { int a1 = 12 ; int a2 = 34 - 5 ; return a1 + a2; } "
try 47 "int main(){return 5+6*7;}"
try 15 "int main(){return 5*(9-6);}"
try 2 "int main(){return (3+5)/2/2;}"
try 2 "int main(){int a=2;return a;}"
try 10 "int main(){int a=2;int b=3+2;return a*b;}"
try 25 "int main(){int a;int b;a=b=3*(3+1);return a+b+1;}"
try 1 "int main(){int a=2;int b=3;a=b=1;return a;}"
try 1 "int main(){int a=2;int b=3;a=b=1;return b;}"
try 0 "int main(){return 10==5;}"
try 1 "int main(){return 10==10;}"
try 1 "int main(){return 10!=5;}"
try 1 "int main(){return 2==2==1;}"
try 1 "int main(){return 2==2!=0;}"
try 1 "int main(){int a=10;return a==10;}"
try 1 "int main(){return 10&&2;}"
try 0 "int main(){return 0&&10;}"
try 0 "int main(){return 10&&0;}"
try 0 "int main(){return 0||0;}"
try 1 "int main(){return 2||0;}"
try 1 "int main(){return 0||2;}"
try 3 "int a=2;int tmp(){a=a+1;return a;}int main(){a&&tmp();return a;}"
try 2 "int a=2;int tmp(){a=a+1;return a;}int main(){0&&tmp();return a;}"
try 2 "int a=2;int tmp(){a=a+1;return a;}int main(){a||tmp();return a;}"
try 3 "int a=2;int tmp(){a=a+1;return a;}int main(){0||tmp();return a;}"
try 69 "int main(){int abc=3;int _23=23;return abc*_23;}"

try 5 "int main(){int a=10;int b=0;if(a==10)b=5;return b;}"
try 5 "int main(){int a=0;if(a=10)a=5;return a;}"
try 0 "int main(){int a=0;if(2*(1-1))a=5;return a;}"
try 1 "int main(){int if0=1;return if0;}"
try 2 "int main(){int a=0;if(0)a=1;else a=2;return a;}"
try 5 "int main(){int a=1; if(a){int b=2;a=3;return a+b;}else{int c=3; return a+c;}}"
try 5 "int main(){int a=1; if(a){int b=2;a=3;return a+b;}else{int b=3; return a+b;}}"
try 5 "int main(){int a=0;for(int i=0; i!=5; i=i+1)a=a+1;return a;}"
try 5 "int main(){int a=0;int i;for (i=0; i!=5; i=i+1) a=a+1;return a;}"
try 5 "int main(){int a=0;do{a=a+1;}while(a!=5);return a;}"
try 10 "int main(){int a=0;do{a=10;}while(0);return a;}"

try 1 "int tmp(){}int main(){tmp();return 1;}"
try 10 "int tmp(){int a=1;}int main(){int a=10;tmp();tmp();return a;}"
try 11 "int tmp(){return 1;}int main(){int a=10;int b=a+tmp();return b;}"
try 1 "int tmp(){if(1)return 1;else return 2;}int main(){return tmp();}"
try 1 "int sum(int a){return a;}int main(){return sum(1);}"
try 12 "int sum(int a, int b){return a+b;}int main(){return sum(sum(1,2),3*(1+2));}"
try 9 "int sum(int a,int b,int c){return a+b+c;}int main(){return sum(2,3,4);}"
try 14 "int sum(int a,int b,int c){int d=5;return a+b+c+d;}int main(){return sum(2,3,4);}"
try 1 "int main(){int a;{a=1;}return a;}"
try 0 "int main(){int a = 0;{int a=1;}return a;}"
try 3 "int x;int y;int main(){x=1;y=2;return x+y;}"
try 2 "int x;int y;int main(){int y=2;return x+y;}"
try 3 "int x;int y=2;int main(){int x=1;return x+y;}"
try 5 "int main(){int a=5;int *b=&a;return *b;}"
try 5 "int main(){int a=5;int *b;b=&a;return *b;}"
try 1 "int main(){int a=5;int *b=&a;*b=1;return a;}"
try 5 "int main(){int a=5;int *b=&a;int **c=&b;return **c;}"
try 1 "int main(){int a=5;int *b=&a;int **c=&b;**c=1;return a;}"
try 6 "int a=5;int *b;int main(){b=&a;*b=*b+1;return a;}"
try 13 "int x=1;int *y;int main(){int a=5;int *b=&a;y=&x;*b=*b+*y*2;*y=*y*20-*b*2;return x+a;}"
try 5 "int main(){int a[2];*a=2;*(a+1)=*a+1;return *(a)+*(a+1);}"
try 5 "int main(){int a[2];a[0]=2;a[1]=a[0]+1;return a[0]+a[1];}"
try 3 "int main(){int a=2;int*b=&a;b[0]=3;return b[0];}"
try 3 "int main(){int a=2;int*b=&a;b[0]=3;return a;}"
try 3 "int main(){int a[2];int*b=a;b[1]=3;return a[1];}"
try 5 "int main(){int a[2][3];a[0][0]=2;a[1][2]=a[0][0]+1;return a[0][0]+a[1][2];}"
try 5 "int a[2][3];int main(){a[0][0]=2;a[1][2]=a[0][0]+1;return a[0][0]+a[1][2];}"
try 8 "int main(){int a;return sizeof(a);}"
try 8 "int main(){int a;return sizeof a;}"
try 8 "int main(){int *a;return sizeof(a);}"
try 64 "int main(){int a[8];return sizeof(a);}"
try 8 "int main(){return sizeof(0);}"

try 1 "int main(){char c=1;return c;}"
try 3 "int main(){char c=1;int a=2;c=a+c;return c;}"
try 9 "int main(){char c[3];c[0]=1;c[1]=3;c[2]=5;return c[0]+c[1]+c[2];}"
try 9 "int main(){char c[3];char *a=c;*(a)=1;*(a+1)=3;*(a+2)=5;return c[0]+c[1]+c[2];}"
try 1 "char tmp(){return 1;}int main(){char c=tmp();return c;}"
try 2 "char buf[1000];char *tmp(){buf[0]=1;buf[1]=2;buf[2]=3;return buf+1;}int main(){char *c=tmp();return c[0];}"

try 97 "int main(){char *s=\"abc\";return s[0];}"
try 98 "int main(){char *s=\"abc\";return s[1];}"
try 99 "int main(){char *s=\"abc\";return s[2];}"
try 0 "int main(){char *s=\"abc\";return s[3];}"
try 7  "int main(){char *s=\"\\a\";return s[0];}"
try 8  "int main(){char *s=\"\\b\";return s[0];}"
try 12  "int main(){char *s=\"\\f\";return s[0];}"
try 10  "int main(){char *s=\"\\n\";return s[0];}"
try 13  "int main(){char *s=\"\\r\";return s[0];}"
try 9  "int main(){char *s=\"\\t\";return s[0];}"
try 11  "int main(){char *s=\"\\v\";return s[0];}"
try 34  "int main(){char *s=\"\\\"\";return s[0];}"
try 39  "int main(){char *s=\"\\'\";return s[0];}"
try 92  "int main(){char *s=\"\\\\\";return s[0];}"
try 97 "char *s=\"abc\";int main(){return s[0];}"
try 98 "char *s=\"abc\";int main(){return s[1];}"
try 99 "char *s=\"abc\";int main(){return s[2];}"
try 0 "char *s=\"abc\";int main(){return s[3];}"

try 3 "int sum(int a, int b);int main() {return sum(1,2);}int sum(int x, int y){return x+y;}"
try 3 "int plus(int a, int b);int main() {return plus(1,2);}"
try 5 "extern int global_arr[1];int main(){return global_arr[0];}"

try 5 "int main(){return 2+({return 3;});}"

echo OK
