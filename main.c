#include<s3c2440.h>
void delay()
{
	int i, j;
	for(i = 0; i < 10000; i ++)
	for(j = 0; j < 50; j ++);
}
int main()
{
	GPBCON = 0x155555;//����protB����������Ϊ���
	while(1)
	{
		//������һ��С��
		GPBDAT |= 0x1E0;
		GPBDAT &= 0x1C0;
		delay();
		//����������С��
		GPBDAT |= 0x1E0;
		GPBDAT &= 0x160;
		delay();
	}
	//return 0;
}
