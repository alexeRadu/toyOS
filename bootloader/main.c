__asm__(".code16\n");

void main()
{
     __asm__ __volatile__ ("movb $'X'  , %al\n");
     __asm__ __volatile__ ("movb $0x0e, %ah\n");
     __asm__ __volatile__ ("int $0x10\n");
}
