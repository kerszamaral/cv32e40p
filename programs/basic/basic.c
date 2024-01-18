typedef unsigned char uint8_t;

static volatile uint8_t *uart = (void *)0x10000000;

static int m_putchar(char ch)
{
    static uint8_t THR = 0x00;
    while((*uart) != 1);
    return *uart = ch;
}

void m_puts(char *s)
{
    while (*s)
        m_putchar(*s++);
    m_putchar('\n');
    m_putchar('\r');
}

int main()
{
    m_puts("Hello RISC-V");
}
