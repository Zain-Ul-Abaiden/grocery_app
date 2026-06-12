"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { LayoutDashboard, Tag, ShoppingBag, ShoppingCart, Image as ImageIcon, Users, LogOut } from "lucide-react";
import { clearSession } from "@/lib/api";

export default function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();

  const handleLogout = () => {
    clearSession();
    router.replace("/login");
  };

  const navItems = [
    { name: "Dashboard", href: "/", icon: LayoutDashboard },
    { name: "Categories", href: "/categories", icon: Tag },
    { name: "Products", href: "/products", icon: ShoppingBag },
    { name: "Orders", href: "/orders", icon: ShoppingCart },
    { name: "Banners", href: "/banners", icon: ImageIcon },
    { name: "Customers", href: "/customers", icon: Users },
  ];

  return (
    <aside className="w-72 bg-[#0F172A] text-white flex-col hidden md:flex shadow-2xl relative">
      <div className="h-20 flex items-center px-8 border-b border-gray-800">
        <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-yellow-400 to-yellow-500 flex items-center justify-center shadow-lg shadow-yellow-500/30">
          <ShoppingBag className="text-gray-900 w-6 h-6" />
        </div>
        <h1 className="text-2xl font-bold ml-4 tracking-tight">Taza<span className="text-yellow-400">Admin</span></h1>
      </div>
      
      <nav className="flex-1 px-4 py-8 space-y-2 overflow-y-auto">
        <p className="px-4 text-xs font-semibold text-gray-500 uppercase tracking-wider mb-4">Management</p>
        
        {navItems.map((item) => {
          const isActive = pathname === item.href;
          const Icon = item.icon;
          return (
            <Link 
              key={item.href} 
              href={item.href} 
              className={`flex items-center px-4 py-3 rounded-xl font-medium transition-all duration-200 ${
                isActive 
                  ? "bg-white/10 text-white shadow-sm" 
                  : "hover:bg-white/5 text-gray-400 hover:text-white"
              }`}
            >
              <Icon className={`w-5 h-5 mr-3 ${isActive ? "text-yellow-400" : ""}`} />
              {item.name}
            </Link>
          );
        })}
      </nav>
      
      <div className="p-6 border-t border-gray-800">
        <button
          onClick={handleLogout}
          className="flex items-center w-full px-4 py-3 rounded-xl hover:bg-red-500/10 text-gray-400 hover:text-red-400 font-medium transition-all duration-200"
        >
          <LogOut className="w-5 h-5 mr-3" />
          Logout
        </button>
      </div>
    </aside>
  );
}
