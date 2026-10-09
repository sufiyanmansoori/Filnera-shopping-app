class ApiResponseModel<T> { const ApiResponseModel({required this.success, this.data, this.message}); final bool success; final T? data; final String? message; }
