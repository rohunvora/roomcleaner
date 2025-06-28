// Script to generate hero image from our test results
const fs = require('fs');
const path = require('path');

// Create a simple HTML template for the hero image
const heroHtml = `
<!DOCTYPE html>
<html>
<head>
<style>
body {
  margin: 0;
  background: #0a0a0a;
  font-family: system-ui;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 600px;
  width: 1200px;
}
.container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 40px;
  padding: 40px;
  width: 100%;
  height: 100%;
}
.side {
  position: relative;
  background: #1a1a1a;
  border-radius: 16px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}
.label {
  position: absolute;
  top: 20px;
  left: 20px;
  background: rgba(0,0,0,0.8);
  color: white;
  padding: 8px 16px;
  border-radius: 8px;
  font-weight: bold;
  font-size: 18px;
  z-index: 10;
}
.image-container {
  flex: 1;
  position: relative;
  background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 300"><rect fill="%23333" width="400" height="300"/><text x="200" y="150" text-anchor="middle" fill="%23666" font-size="20">Messy Room Photo</text></svg>');
  background-size: cover;
  background-position: center;
}
.box {
  position: absolute;
  border: 2px solid #17ff80;
  background: rgba(23, 255, 128, 0.1);
}
.box-label {
  position: absolute;
  top: -24px;
  left: 0;
  background: #17ff80;
  color: black;
  padding: 2px 8px;
  font-size: 12px;
  font-weight: bold;
  border-radius: 4px;
  white-space: nowrap;
}
.stats {
  position: absolute;
  bottom: 20px;
  right: 20px;
  background: rgba(0,0,0,0.8);
  color: #17ff80;
  padding: 12px 20px;
  border-radius: 8px;
  font-weight: bold;
  font-size: 24px;
}
</style>
</head>
<body>
<div class="container">
  <div class="side">
    <div class="label">BEFORE</div>
    <div class="image-container"></div>
  </div>
  <div class="side">
    <div class="label">AI DETECTED</div>
    <div class="image-container">
      <div class="box" style="left: 10%; top: 20%; width: 15%; height: 20%;">
        <div class="box-label">shirt</div>
      </div>
      <div class="box" style="left: 30%; top: 40%; width: 20%; height: 15%;">
        <div class="box-label">laptop</div>
      </div>
      <div class="box" style="left: 60%; top: 30%; width: 10%; height: 15%;">
        <div class="box-label">water bottle</div>
      </div>
      <div class="box" style="left: 70%; top: 60%; width: 15%; height: 10%;">
        <div class="box-label">papers</div>
      </div>
      <div class="box" style="left: 20%; top: 70%; width: 12%; height: 12%;">
        <div class="box-label">charger</div>
      </div>
      <div class="box" style="left: 45%; top: 65%; width: 8%; height: 10%;">
        <div class="box-label">pen</div>
      </div>
    </div>
    <div class="stats">23 items detected</div>
  </div>
</div>
</body>
</html>
`;

// Save HTML file
fs.writeFileSync(path.join(__dirname, 'hero-template.html'), heroHtml);

console.log('Hero template created. Open hero-template.html in browser and take screenshot.');
console.log('Then save as public/hero.webp (1200x600px)