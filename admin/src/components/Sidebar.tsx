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
    <aside className="w-72 bg-[#143F17] text-white flex-col hidden md:flex shadow-2xl relative">
      <div className="h-20 flex items-center px-8 border-b border-white/10">
        <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-[#8ABF2C] to-[#2F6B1A] flex items-center justify-center shadow-lg shadow-[#2F6B1A]/40">
          <ShoppingBag className="text-white w-6 h-6" />
        </div>
        <h1 className="text-lg font-bold ml-3 tracking-tight leading-tight">Shadab Super <span className="text-[#B4EB39]">Store</span></h1>
      </div>
      
      <nav className="flex-1 px-4 py-8 space-y-2 overflow-y-auto">
        <p className="px-4 text-xs font-semibold text-white/40 uppercase tracking-wider mb-4">Management</p>
        
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
              <Icon className={`w-5 h-5 mr-3 ${isActive ? "text-[#B4EB39]" : ""}`} />
              {item.name}
            </Link>
          );
        })}
      </nav>
      
      <div className="p-6 border-t border-white/10">
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
