// Hardcoded detection data for the demo
// Positions are percentage-based for responsive design
export const hardcodedDetections = [
  // Clothing items (blue)
  { id: 1, x: 15, y: 65, width: 8, height: 10, label: "T-shirt", category: "clothing" as const, delay: 0 },
  { id: 2, x: 25, y: 70, width: 6, height: 8, label: "Jeans", category: "clothing" as const, delay: 100 },
  { id: 3, x: 70, y: 80, width: 7, height: 6, label: "Socks", category: "clothing" as const, delay: 200 },
  { id: 4, x: 45, y: 75, width: 5, height: 7, label: "Hoodie", category: "clothing" as const, delay: 300 },
  
  // Electronics (green)
  { id: 5, x: 30, y: 40, width: 6, height: 4, label: "Phone", category: "electronics" as const, delay: 400 },
  { id: 6, x: 55, y: 35, width: 10, height: 6, label: "Laptop", category: "electronics" as const, delay: 500 },
  { id: 7, x: 40, y: 45, width: 4, height: 5, label: "Earbuds", category: "electronics" as const, delay: 600 },
  { id: 8, x: 65, y: 50, width: 8, height: 5, label: "Tablet", category: "electronics" as const, delay: 700 },
  
  // Books/Papers (purple)
  { id: 9, x: 10, y: 50, width: 7, height: 5, label: "Textbook", category: "books" as const, delay: 800 },
  { id: 10, x: 20, y: 55, width: 5, height: 3, label: "Notebook", category: "books" as const, delay: 900 },
  { id: 11, x: 75, y: 60, width: 6, height: 4, label: "Papers", category: "books" as const, delay: 1000 },
  { id: 12, x: 35, y: 58, width: 8, height: 3, label: "Magazine", category: "books" as const, delay: 1100 },
  
  // Personal items (amber)
  { id: 13, x: 50, y: 30, width: 5, height: 5, label: "Keys", category: "personal" as const, delay: 1200 },
  { id: 14, x: 60, y: 65, width: 6, height: 8, label: "Backpack", category: "personal" as const, delay: 1300 },
  { id: 15, x: 25, y: 35, width: 4, height: 6, label: "Wallet", category: "personal" as const, delay: 1400 },
  { id: 16, x: 80, y: 70, width: 7, height: 5, label: "Shoes", category: "personal" as const, delay: 1500 },
  
  // Misc items (gray)
  { id: 17, x: 12, y: 75, width: 5, height: 4, label: "Water bottle", category: "misc" as const, delay: 1600 },
  { id: 18, x: 68, y: 40, width: 6, height: 6, label: "Snacks", category: "misc" as const, delay: 1700 },
  { id: 19, x: 42, y: 65, width: 4, height: 3, label: "Pen", category: "misc" as const, delay: 1800 },
  { id: 20, x: 85, y: 45, width: 5, height: 7, label: "Cup", category: "misc" as const, delay: 1900 },
  
  // More clothing scattered around
  { id: 21, x: 5, y: 85, width: 7, height: 5, label: "Cap", category: "clothing" as const, delay: 2000 },
  { id: 22, x: 52, y: 85, width: 8, height: 6, label: "Jacket", category: "clothing" as const, delay: 2100 },
  { id: 23, x: 33, y: 80, width: 6, height: 4, label: "Belt", category: "clothing" as const, delay: 2200 },
  
  // Additional electronics
  { id: 24, x: 18, y: 45, width: 5, height: 3, label: "Charger", category: "electronics" as const, delay: 2300 },
  { id: 25, x: 72, y: 55, width: 4, height: 4, label: "Mouse", category: "electronics" as const, delay: 2400 },
  
  // Final items
  { id: 26, x: 90, y: 80, width: 6, height: 5, label: "Towel", category: "clothing" as const, delay: 2500 },
  { id: 27, x: 8, y: 60, width: 5, height: 6, label: "Books", category: "books" as const, delay: 2600 },
  { id: 28, x: 48, y: 50, width: 7, height: 4, label: "Glasses", category: "personal" as const, delay: 2700 },
  { id: 29, x: 62, y: 75, width: 5, height: 5, label: "Watch", category: "personal" as const, delay: 2800 },
  { id: 30, x: 38, y: 70, width: 6, height: 3, label: "Remote", category: "electronics" as const, delay: 2900 },
]