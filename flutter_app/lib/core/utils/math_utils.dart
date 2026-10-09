class MathUtils { static double average(List<double> values) => values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length; }
