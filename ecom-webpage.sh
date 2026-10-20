#!/bin/bash
set -euxo pipefail

# Install and start Nginx on Ubuntu
apt-get update -y
apt-get install -y nginx

systemctl enable nginx
systemctl start nginx

# Create the e-commerce website
cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ShopSphere | Online Shopping</title>

<style>
:root {
  --blue: #0866f5;
  --navy: #102746;
  --muted: #667085;
  --light: #f4f7fc;
}

* { box-sizing: border-box; }

body {
  margin: 0;
  font-family: Arial, Helvetica, sans-serif;
  color: var(--navy);
  background: white;
}

button, input { font: inherit; }
button { cursor: pointer; }

header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 22px;
  padding: 18px 7%;
  border-bottom: 1px solid #e9edf4;
  background: white;
  position: sticky;
  top: 0;
  z-index: 5;
}

.logo {
  font-size: 27px;
  font-weight: 800;
  white-space: nowrap;
}

.logo span { color: var(--blue); }

nav { display: flex; gap: 24px; }
nav a {
  color: var(--navy);
  text-decoration: none;
  font-size: 14px;
}

nav a:hover { color: var(--blue); }

.search {
  display: flex;
  border: 1px solid #dce3ed;
  border-radius: 30px;
  padding: 5px 14px;
  background: #fafbfe;
}

.search input {
  width: 155px;
  border: 0;
  outline: 0;
  background: transparent;
  padding: 7px;
}

.cart-button {
  border: 0;
  background: white;
  color: var(--navy);
  font-weight: bold;
  font-size: 16px;
}

main { padding: 18px 3% 35px; }

.hero {
  display: flex;
  align-items: center;
  min-height: 300px;
  padding: 45px 7%;
  border-radius: 14px;
  overflow: hidden;
  background:
    linear-gradient(90deg, #eaf3ff 0%, #edf5ff 48%, #dbe9f9 100%);
}

.hero-content { max-width: 520px; }

.eyebrow {
  color: var(--blue);
  font-weight: bold;
  letter-spacing: 2px;
  font-size: 13px;
}

.hero h1 {
  font-size: clamp(34px, 5vw, 54px);
  line-height: 1.1;
  margin: 14px 0;
}

.hero p {
  color: #526176;
  font-size: 17px;
  line-height: 1.7;
}

.primary {
  background: var(--blue);
  color: white;
  border: 0;
  border-radius: 7px;
  padding: 13px 22px;
  font-weight: bold;
}

.primary:hover { background: #004ec7; }

.benefits {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  padding: 27px 3%;
  border-bottom: 1px solid #e6ebf2;
}

.benefit { display: flex; align-items: center; gap: 12px; }
.benefit-icon {
  background: #eaf2ff;
  color: var(--blue);
  border-radius: 50%;
  padding: 14px;
  font-size: 20px;
}

.benefit strong { font-size: 14px; }
.benefit p { color: var(--muted); font-size: 12px; margin-bottom: 0; }

.section-heading {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin: 30px 0 20px;
}

.section-heading h2 { margin: 0; font-size: 27px; }

.filters {
  display: flex;
  flex-wrap: wrap;
  gap: 9px;
  margin-bottom: 22px;
}

.filter {
  border: 1px solid #dbe3ef;
  background: white;
  border-radius: 22px;
  padding: 9px 16px;
  color: var(--navy);
}

.filter.active, .filter:hover {
  background: var(--blue);
  border-color: var(--blue);
  color: white;
}

.products {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 20px;
}

.product {
  border: 1px solid #e1e7ef;
  border-radius: 11px;
  overflow: hidden;
  background: white;
  transition: transform .2s, box-shadow .2s;
}

.product:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 25px #172d4a12;
}

.product img {
  display: block;
  width: 100%;
  height: 190px;
  object-fit: contain;
  padding: 14px;
  background: #f7f8fa;
}

.product-info { padding: 15px; }
.product h3 { font-size: 16px; margin: 0 0 9px; }
.price { color: var(--blue); font-weight: bold; font-size: 19px; }
.rating { color: #f5a623; margin: 9px 0 14px; }
.rating small { color: var(--muted); }

.add {
  width: 100%;
  background: var(--blue);
  color: white;
  border: 0;
  border-radius: 6px;
  padding: 12px 8px;
  font-weight: bold;
}

.add:hover { background: #004ec7; }

.empty {
  display: none;
  padding: 35px 0;
  color: var(--muted);
}

footer {
  background: #102746;
  color: white;
  padding: 28px 7%;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 18px;
  flex-wrap: wrap;
}

footer p { color: #d2dbea; font-size: 13px; }
footer a { color: white; text-decoration: none; margin-right: 15px; }

@media (max-width: 900px) {
  header { flex-wrap: wrap; padding: 16px 4%; }
  .products { grid-template-columns: repeat(2, minmax(0, 1fr)); }
  .benefits { grid-template-columns: repeat(2, 1fr); }
  nav { order: 3; width: 100%; justify-content: center; }
}

@media (max-width: 520px) {
  .hero { padding: 35px 22px; }
  .benefits { grid-template-columns: 1fr 1fr; gap: 15px; }
  .products { gap: 10px; }
  .product img { height: 130px; }
  .product-info { padding: 10px; }
  .product h3 { font-size: 14px; }
  .price { font-size: 16px; }
  .search input { width: 110px; }
  .section-heading h2 { font-size: 21px; }
}
</style>
</head>

<body>

<header>
  <div class="logo">Shop<span>Sphere</span></div>

  <nav>
    <a href="#">Home</a>
    <a href="#products">Products</a>
    <a href="#benefits">Why Us</a>
    <a href="#contact">Contact</a>
  </nav>

  <div class="search">
    <input id="search" type="search" placeholder="Search products..."
           aria-label="Search products">
    <span>⌕</span>
  </div>

  <button class="cart-button" onclick="showCart()">
    🛒 Cart (<span id="cart-count">0</span>)
  </button>
</header>

<main>
  <section class="hero">
    <div class="hero-content">
      <div class="eyebrow">WELCOME TO SHOPSPHERE</div>
      <h1>Everything You Love, All in One Place.</h1>
      <p>Discover trending technology, everyday essentials and
         accessories at prices you'll love.</p>
      <button class="primary"
              onclick="document.getElementById('products').scrollIntoView({behavior:'smooth'})">
        Shop Now &nbsp; →
      </button>
    </div>
  </section>

  <section class="benefits" id="benefits">
    <div class="benefit">
      <span class="benefit-icon">🚚</span>
      <div><strong>Free Shipping</strong><p>On orders over ₹999</p></div>
    </div>
    <div class="benefit">
      <span class="benefit-icon">🔒</span>
      <div><strong>Secure Shopping</strong><p>Shop with confidence</p></div>
    </div>
    <div class="benefit">
      <span class="benefit-icon">🎧</span>
      <div><strong>Customer Support</strong><p>We're here to help</p></div>
    </div>
    <div class="benefit">
      <span class="benefit-icon">↩</span>
      <div><strong>Easy Returns</strong><p>Simple return process</p></div>
    </div>
  </section>

  <section id="products">
    <div class="section-heading">
      <h2>Featured Products</h2>
      <span id="result-count"></span>
    </div>

    <div class="filters">
      <button class="filter active" data-category="All">All Products</button>
      <button class="filter" data-category="Electronics">Electronics</button>
      <button class="filter" data-category="Accessories">Accessories</button>
      <button class="filter" data-category="Lifestyle">Lifestyle</button>
    </div>

    <div class="products" id="product-grid">

      <article class="product" data-name="Wireless Earbuds"
               data-category="Electronics" data-price="1499">
        <img src="https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?auto=format&fit=crop&w=600&q=80"
             alt="Wireless earbuds" loading="lazy">
        <div class="product-info">
          <h3>Wireless Earbuds</h3>
          <div class="price">₹1,499</div>
          <div class="rating">★★★★★ <small>(4.8)</small></div>
          <button class="add" onclick="addToCart(this)">Add to Cart</button>
        </div>
      </article>

      <article class="product" data-name="Smart Watch"
               data-category="Electronics" data-price="2499">
        <img src="https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=600&q=80"
             alt="Smart watch" loading="lazy">
        <div class="product-info">
          <h3>Smart Watch</h3>
          <div class="price">₹2,499</div>
          <div class="rating">★★★★★ <small>(4.7)</small></div>
          <button class="add" onclick="addToCart(this)">Add to Cart</button>
        </div>
      </article>

      <article class="product" data-name="Travel Backpack"
               data-category="Lifestyle" data-price="1299">
        <img src="https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=600&q=80"
             alt="Travel backpack" loading="lazy">
        <div class="product-info">
          <h3>Travel Backpack</h3>
          <div class="price">₹1,299</div>
          <div class="rating">★★★★★ <small>(4.6)</small></div>
          <button class="add" onclick="addToCart(this)">Add to Cart</button>
        </div>
      </article>

      <article class="product" data-name="Wireless Headphones"
               data-category="Electronics" data-price="1999">
        <img src="https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=600&q=80"
             alt="Premium headphones" loading="lazy">
        <div class="product-info">
          <h3>Wireless Headphones</h3>
          <div class="price">₹1,999</div>
          <div class="rating">★★★★★ <small>(4.9)</small></div>
          <button class="add" onclick="addToCart(this)">Add to Cart</button>
        </div>
      </article>

      <article class="product" data-name="Classic Sunglasses"
               data-category="Accessories" data-price="799">
        <img src="https://images.unsplash.com/photo-1511499767150-a48a237f0083?auto=format&fit=crop&w=600&q=80"
             alt="Sunglasses" loading="lazy">
        <div class="product-info">
          <h3>Classic Sunglasses</h3>
          <div class="price">₹799</div>
          <div class="rating">★★★★☆ <small>(4.4)</small></div>
          <button class="add" onclick="addToCart(this)">Add to Cart</button>
        </div>
      </article>

      <article class="product" data-name="Everyday Sneakers"
               data-category="Lifestyle" data-price="1799">
        <img src="https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=600&q=80"
             alt="Red sneakers" loading="lazy">
        <div class="product-info">
          <h3>Everyday Sneakers</h3>
          <div class="price">₹1,799</div>
          <div class="rating">★★★★★ <small>(4.7)</small></div>
          <button class="add" onclick="addToCart(this)">Add to Cart</button>
        </div>
      </article>

      <article class="product" data-name="Modern Wrist Watch"
               data-category="Accessories" data-price="1599">
        <img src="https://images.unsplash.com/photo-1524805444758-089113d48a6d?auto=format&fit=crop&w=600&q=80"
             alt="Classic wrist watch" loading="lazy">
        <div class="product-info">
          <h3>Modern Wrist Watch</h3>
          <div class="price">₹1,599</div>
          <div class="rating">★★★★☆ <small>(4.5)</small></div>
          <button class="add" onclick="addToCart(this)">Add to Cart</button>
        </div>
      </article>

      <article class="product" data-name="Camera Backpack"
               data-category="Accessories" data-price="2199">
        <img src="https://images.unsplash.com/photo-1622560480654-d96214fdc887?auto=format&fit=crop&w=600&q=80"
             alt="Everyday backpack" loading="lazy">
        <div class="product-info">
          <h3>Camera Backpack</h3>
          <div class="price">₹2,199</div>
          <div class="rating">★★★★★ <small>(4.6)</small></div>
          <button class="add" onclick="addToCart(this)">Add to Cart</button>
        </div>
      </article>

    </div>

    <p class="empty" id="empty-message">No matching products found.</p>
  </section>
</main>

<footer id="contact">
  <div>
    <div class="logo">Shop<span>Sphere</span></div>
    <p>Your everyday shopping destination.</p>
  </div>
  <div>
    <a href="#">Home</a>
    <a href="#products">Products</a>
    <a href="#contact">Contact</a>
  </div>
  <p>© 2026 ShopSphere. Demo store.</p>
</footer>

<script>
let cart = [];
let activeCategory = "All";

const cards = [...document.querySelectorAll(".product")];
const search = document.getElementById("search");

function renderProducts() {
  const term = search.value.trim().toLowerCase();
  let visible = 0;

  cards.forEach(card => {
    const matchesName = card.dataset.name.toLowerCase().includes(term);
    const matchesCategory = activeCategory === "All" ||
                            card.dataset.category === activeCategory;
    const show = matchesName && matchesCategory;

    card.style.display = show ? "" : "none";
    if (show) visible++;
  });

  document.getElementById("result-count").textContent =
    visible + " products";
  document.getElementById("empty-message").style.display =
    visible ? "none" : "block";
}

search.addEventListener("input", renderProducts);

document.querySelectorAll(".filter").forEach(button => {
  button.addEventListener("click", () => {
    activeCategory = button.dataset.category;

    document.querySelectorAll(".filter").forEach(item =>
      item.classList.toggle("active", item === button)
    );

    renderProducts();
  });
});

function addToCart(button) {
  const product = button.closest(".product");

  cart.push({
    name: product.dataset.name,
    price: Number(product.dataset.price)
  });

  document.getElementById("cart-count").textContent = cart.length;

  button.textContent = "Added ✓";
  setTimeout(() => button.textContent = "Add to Cart", 900);
}

function showCart() {
  if (!cart.length) {
    alert("Your cart is empty. Add a product to get started!");
    return;
  }

  const total = cart.reduce((sum, item) => sum + item.price, 0);
  const items = cart.map(item =>
    item.name + " - ₹" + item.price.toLocaleString("en-IN")
  ).join("\n");

  alert("YOUR SHOPPING CART\n\n" + items +
        "\n\nTotal: ₹" + total.toLocaleString("en-IN") +
        "\n\nDemo only: checkout is not connected.");
}

renderProducts();
</script>

</body>
</html>
HTML

# Set ownership and permissions
chown root:root /var/www/html/index.html
chmod 644 /var/www/html/index.html

# Validate Nginx and reload
nginx -t
systemctl reload nginx

echo "ShopSphere e-commerce website deployed successfully!"
