class StringUtils { static String trimToLength(String value, int maxLength) => value.length > maxLength ? '${value.substring(0, maxLength)}...' : value; }
