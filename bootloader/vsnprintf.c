__asm__(".code16gcc\n");

#include <stdarg.h>

int vsnprintf(char *buf, int size, const char *fmt, va_list args)
{
	int read = 0;

	while (1) {
		if (*fmt == 0)
			break;

		if (read >= size)
			break;

		if (*fmt != '%') {
			*buf = *fmt;
			buf++;
			read++;
		}

		fmt++;
	}

	return read;
}

int snprintf(char *buf, int size, const char *fmt, ...)
{
	va_list vl;
	int ret;

	va_start(vl, fmt);
	ret = vsnprintf(buf, size, fmt, vl);
	va_end(vl);

	return ret;
}
