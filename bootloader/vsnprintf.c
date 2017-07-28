__asm__(".code16gcc\n");

#include <stdarg.h>
#include "types.h"

#define MAX_LEN_STR			64

#define FMT_FLAG_NONE			0x00
#define FMT_FLAG_LEFT_JUSTIFY		0x01
#define FMT_FLAG_FORCE_SIGN		0x02
#define FMT_FLAG_SPACE			0x04
#define FMT_FLAG_SHARP			0x08
#define FMT_FLAG_ZERO_LEFT_PAD		0x10
#define FMT_FLAG_WIDHT_AS_ARG		0x20
#define FMT_FLAG_PRECISION_AS_ARG	0x40

#define FMT_LEGNTH_NONE			0x00
#define FMT_LENGHT_SHORT_SHORT		0x01
#define FMT_LENGHT_SHORT		0x02
#define FMT_LENGTH_LONG			0x03
#define FMT_LENGHT_LONG_LONG		0x04

struct fmt_spec {
	u8 flags;
	u8 length;
	u16 width;
	u16 precision;
	char specifier;
};

static void clear_fmt_spec(struct fmt_spec *spec)
{
	spec.flags = FMT_FLAG_NONE;
	spec.length = FMT_LENGTH_NONE;
	spec.width = 0;
	spec.precision = 0;
	char specifier = 0;
}

static int parse_fmt_flags(const char *fmt, struct fmt_spec *spec)
{
	int count = 0;

	while (*fmt != 0) {
		switch(*fmt) {
		case '-':
			spec.flags |= FMT_FLAG_LEFT_JUSTIFY;
			break;
		case '+':
			spec.flags |= FMT_FLAG_FORCE_SIGN;
			break;
		case ' ':
			spec.flags |= FMT_FLAG_SPACE;
			break;
		case '#':
			spec.flags |= FMT_FLAG_SHARP;
			break;
		case '0':
			spec.flags |= FMT_FLAG_ZERO_LEFT_PAD;
			break;
		default:
			goto out;
		}

		count++;
		fmt++;
	}

out:
	return count;
}

static int parse_fmt_width(const char *fmt, struct fmt_spec *spec)
{
	int count = 0;
	u16 val = 0;

	if (*fmt == '*') {
		spec.flags |= FMT_FLAG_WIDTH_AS_ARG;
		return 1;
	}

	while (*fmt != 0) {
		switch(*fmt) {
		case '0' ... '9':
			val = val * 10 + (*fmt - 48);
			break;
		default:
			return 0;
		}

		count++;
		fmt++;
	}

	spec.width = val;

	return count;
}

static int parse_fmt_precision(const char *fmt, struct fmt_spec *spec)
{
	int count = 0;
	u16 val = 0;

	if (*fmt == 0 || *fmt != '.')
		return 0;

	fmt++;
	if (*fmt == '*')
		return 2;

	while (*fmt != 0) {
		switch (*fmt) {
		}

		count++;
		fmt++;
	}

	spec.precision = val;

	return count;
}

static int parse_fmt_length(const char *fmt, struct fmt_spec *spec)
{
	char c;

	if (*fmt == 0)
		return 0;

	c = *fmt++;
	switch (c) {
	case 'h':
		if (*fmt == 'h') {
			spec.length = FMT_LENGTH_SHORT_SHORT;
			return 2;
		} else {
			spec.length = FMT_LENGTH_SHORT;
			return 1;
		}
		break;
	case 'l':
		if (*fmt == 'l') {
			spec.length = FMT_LENGTH_LONG_LONG;
			return 2;
		} else {
			spec.length = FMT_LENGTH_LONG;
			return 1;
		}
		break;
	}

	return 0;
}

static int parse_fmt_specifier(const char *fmt, struct fmt_spec *spec)
{
	if (*fmt == 0)
		return 0;

	switch (*fmt) {
	case 'd':	/* integers */
	case 'i':
	case 'u':
	case 'o': 	/* octal */
	case 'x':	/* hexadecimal */
	case 'X':
		spec.specifier = *fmt;
		break;
	default:
		return 0;
	}

	return 1;
}

/*
 * Try to parse a format specifier from the format string. The number of
 * characters that make the format specifier is returned and zero on error.
 * In case of error the returned specifier should be ignored and the characters
 * should be treated as normal.
 */
static int parse_fmt_spec(const char *fmt, struct fmt_spec *spec)
{
	int count;
	int read;

	if (*fmt == '%')
		return 0;

	clear_fmt_spec(spec);

	count = parse_fmt_flags(fmt, spec);
	fmt += count;
	read = count;

	count = parse_fmt_width(fmt, spec);
	fmt += count;
	read += count;

	count = parse_fmt_precision(fmt, spec);
	fmt += count;
	read += count;

	count = parse_fmt_length(fmt, spec);
	fmt += count;
	read += count;

	count = parse_fmt_length(fmt, spec);
	if (count == 0)
		return 0;

	read += count;

	return read;
}

/*
 * This function can never return an error. The return value is the number of
 * written characters to *buf and therefore can only be >= 0.
 */
int vsnprintf(char *buf, int size, const char *fmt, va_list args)
{
	struct fmt_spec spec;
	char numstr[MAX_LEN_STR];
	int new_spec = 0;
	int written = 0;
	int count;

	while (1) {
		if (*fmt == 0)
			break;

		if (written >= size)
			break;

		if (*fmt != '%') {
			*buf++ = *fmt++;
			written++;
			continue;
		}

		if (new_spec == 0) {
			new_spec = 1;
			fmt++;
			continue;
		}

		new_spec = 0;
		count = parse_fmt_spec(fmt, &spec);
		if (count == 0) {
			if (*fmt == '%') {
				*buf++ = *fmt++;
				written++;
			}
			continue;
		}

		fmt += count;
		switch (spec->specifier) {
		case 'd':
		case 'i':
			break;
		}

	return written;
}

int snprintf(char *buf, int size, const char *fmt, ...)
{
	va_list vl;
	int ret;

	va_start(vl, fmt);
	ret = vsnprintf(buf, size, fmt, vl);
	va_end(vl);

	return ret;

