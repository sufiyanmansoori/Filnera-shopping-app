class CardFormatter { static String mask(String value) => value.length > 4 ? '**** **** **** ${value.substring(value.length - 4)}' : value; }
