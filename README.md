# Convolution Operation in MIPS Assembly

## 🖊️ Overview
This project implements a **convolution operation** in **MIPS assembly language**, a fundamental operation in image and signal processing. The program performs convolution on a 2D image matrix using a kernel matrix, supporting padding, stride, and error handling.

---

## ✨ Features
- **Input Handling**: Reads matrix and kernel data from an input file with validation.
- **Convolution Logic**:
  - Padding and stride configurations.
  - Validates kernel size against image dimensions.
  - Handles floating-point arithmetic for precision.
- **Output Generation**:
  - Writes the resulting matrix to an output file.
  - Includes custom floating-point to string conversion for clean formatting.
- **Error Handling**:
  - Ensures valid input parameters (e.g., matrix size, kernel dimensions).
  - Generates detailed error messages for invalid configurations.

---

## 🛠 Technologies
- **MIPS Assembly Language**
- **SPIM**/MARS Simulator for execution
- **File I/O Operations**
- **Stack-based Memory Management**

---

## 🚀 How It Works
1. **Input Processing**:  
   Reads input from a `.txt` file containing:
   - Matrix dimensions (N x N)
   - Kernel dimensions (M x M)
   - Padding (P) and stride (S)
   - Image matrix and kernel matrix.

2. **Convolution Logic**:
   - Validates kernel size.
   - Applies padding and calculates the output size using the formula:  
     ```
     outputSize = ((N + 2P - M) / S) + 1
     ```
   - Performs element-wise multiplication and summation for each kernel position.

3. **Output Generation**:  
   - Writes the resulting matrix to an output file.
   - Handles formatted floating-point output.

---

## 💂️ File Structure
```
project-folder/
├── input.txt              # Sample input file
├── output_matrix.txt      # Generated output file
├── convolution.asm        # MIPS assembly source code
├── README.md              # Project documentation
└── test_cases/            # Folder containing test inputs
```

---

## 🪓 Test Cases
### Example Input:
```
N = 5, M = 3, P = 1, S = 1
Image Matrix:
1 2 3 4 5
6 7 8 9 10
11 12 13 14 15
16 17 18 19 20
21 22 23 24 25
Kernel Matrix:
1 0 -1
2 0 -2
1 0 -1
```

### Example Output:
```
Result Matrix:
-24 -28 -32 -36 -40
-40 -44 -48 -52 -56
-56 -60 -64 -68 -72
-72 -76 -80 -84 -88
-88 -92 -96 -100 -104
```

---

## 🖍 Instructions to Run
1. Clone the repository:
   ```bash
   git clone https://github.com/Hatcodechet/Convolution-Operation-in-MIPS-Assembly.git
   cd Convolution-Operation-in-MIPS-Assembly
   ```
2. Open the `convolution.asm` file in a MIPS simulator (e.g., **MARS** or **SPIM**).
3. Provide the input in the `input.txt` file.
4. Run the program and check the results in `output_matrix.txt`.

---

## 🌟 Key Learning Outcomes
- Low-level programming with **MIPS assembly**.
- Efficient use of stack operations and floating-point arithmetic.
- Practical implementation of a convolution operation with real-world use cases.

---

## 📨 Contact
For any questions or collaboration, feel free to reach out!  
**Author**: Phạm Nguyễn Viết Trí  
**Email**: [viettri.icco@gmail.com]  
**GitHub**: [Hatcodechet](https://github.com/Hatcodechet)
