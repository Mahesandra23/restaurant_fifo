class ArrayFifoQueue<T> {
  final int maxSize;
  late List<T?> _queue;
  int _front = -1;
  int _rear = -1;

  // Constructor dengan ukuran array, default 20 seperti yang Anda minta
  ArrayFifoQueue(this.maxSize) {
    // Membuat array statis dengan ukuran pasti (fixed-length array di Dart)
    _queue = List<T?>.filled(maxSize, null, growable: false);
  }

  // Mengecek apakah antrean kosong
  bool isEmpty() {
    return _front == -1;
  }

  // Mengecek apakah antrean penuh (Circular check)
  bool isFull() {
    return (_rear + 1) % maxSize == _front;
  }

  // ENQUEUE: Menambahkan pesanan baru di posisi REAR
  bool enqueue(T item) {
    if (isFull()) {
      print("Antrean Penuh! Tidak bisa menambah pesanan.");
      return false; // Gagal masuk antrean
    }

    if (isEmpty()) {
      // Jika antrean benar-benar kosong, inisialisasi pointer
      _front = 0;
      _rear = 0;
    } else {
      // Geser rear ke posisi berikutnya (dengan logika melingkar)
      _rear = (_rear + 1) % maxSize;
    }

    _queue[_rear] = item;
    return true; // Berhasil masuk antrean
  }

  // DEQUEUE: Mengeluarkan pesanan yang sudah selesai dari posisi FRONT
  T? dequeue() {
    if (isEmpty()) {
      print("Antrean Kosong! Tidak ada pesanan yang bisa dikeluarkan.");
      return null;
    }

    T? dequeuedItem = _queue[_front];
    _queue[_front] = null; // Bersihkan memori

    if (_front == _rear) {
      // Jika ini adalah elemen terakhir di antrean, reset pointer
      _front = -1;
      _rear = -1;
    } else {
      // Geser front ke pesanan berikutnya (dengan logika melingkar)
      _front = (_front + 1) % maxSize;
    }

    return dequeuedItem;
  }

  // PEEK: Melihat pesanan paling depan tanpa mengeluarkannya
  T? peek() {
    if (isEmpty()) return null;
    return _queue[_front];
  }

  // Fungsi tambahan untuk UI Flutter: Mengubah queue ke bentuk List biasa
  // agar mudah ditampilkan di ListView.builder
  List<T> toList() {
    if (isEmpty()) return [];
    
    List<T> result = [];
    int current = _front;
    
    while (true) {
      result.add(_queue[current]!);
      if (current == _rear) break;
      current = (current + 1) % maxSize;
    }
    
    return result;
  }
}