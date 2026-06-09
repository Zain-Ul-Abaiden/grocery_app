import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import Link from "next/link";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Cartfily MVP Admin",
  description: "Admin panel for Grocery App",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${inter.className} bg-gray-50 flex h-screen overflow-hidden`}>
        {/* Sidebar */}
        <aside className="w-64 bg-white border-r flex flex-col hidden md:flex">
          <div className="h-16 flex items-center justify-center border-b">
            <h1 className="text-xl font-bold text-gray-800">Admin Panel</h1>
          </div>
          <nav className="flex-1 p-4 space-y-2">
            <Link href="/" className="block p-3 rounded hover:bg-gray-100 font-medium">Dashboard</Link>
            <Link href="/categories" className="block p-3 rounded hover:bg-gray-100 font-medium">Categories</Link>
            <Link href="/products" className="block p-3 rounded hover:bg-gray-100 font-medium">Products</Link>
            <Link href="/orders" className="block p-3 rounded hover:bg-gray-100 font-medium">Orders</Link>
            <Link href="/banners" className="block p-3 rounded hover:bg-gray-100 font-medium">Banners</Link>
            <Link href="/customers" className="block p-3 rounded hover:bg-gray-100 font-medium">Customers</Link>
          </nav>
        </aside>

        {/* Main Content */}
        <main className="flex-1 flex flex-col h-screen overflow-y-auto">
          {/* Mobile Header */}
          <header className="h-16 bg-white border-b flex items-center px-4 md:hidden">
             <h1 className="text-xl font-bold text-gray-800">Admin Panel</h1>
          </header>
          
          <div className="p-6">
            {children}
          </div>
        </main>
      </body>
    </html>
  );
}
