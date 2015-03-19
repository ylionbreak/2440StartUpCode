#include<s3c2440.h>
int main()
{
while(1)
{
//点亮第一个小灯
GPBDAT |= 0x1E0;
GPBDAT &= 0x1C0;
delay();
//点亮第二个小灯
GPBDAT |= 0x1E0;
GPBDAT &= 0x1A0;
delay();
//点亮第三个小灯
GPBDAT |= 0x1E0;
GPBDAT &= 0x160;
delay();
//点亮第四个小灯
GPBDAT |= 0x1E0;
GPBDAT &= 0x0E0;
delay();
}
}