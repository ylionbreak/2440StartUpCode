#include<s3c2440.h>
int main()
{
while(1)
{
//������һ��С��
GPBDAT |= 0x1E0;
GPBDAT &= 0x1C0;
delay();
//�����ڶ���С��
GPBDAT |= 0x1E0;
GPBDAT &= 0x1A0;
delay();
//����������С��
GPBDAT |= 0x1E0;
GPBDAT &= 0x160;
delay();
//�������ĸ�С��
GPBDAT |= 0x1E0;
GPBDAT &= 0x0E0;
delay();
}
}