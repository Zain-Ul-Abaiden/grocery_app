"use client";

import { useEffect, useState } from "react";
import { usePathname, useRouter } from "next/navigation";
import { Bell, Loader2 } from "lucide-react";
import Sidebar from "@/components/Sidebar";
import { getToken, getUser, type AdminUser } from "@/lib/api";

const TITLES: Record<string, string> = {
  "/": "Dashboard",
  "/categories": "Categories",
  "/products": "Products",
  "/orders": "Orders",
  "/banners": "Banners",
  "/customers": "Customers",
};

export default function AppShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const [ready, setReady] = useState(false);
  const [user, setUser] = useState<AdminUser | null>(null);

  const isLoginPage = pathname === "/login";

  useEffect(() => {
    if (isLoginPage) {
      setReady(true);
      return;
    }
    const token = getToken();
    if (!token) {
      router.replace("/login");
      return;
    }
    setUser(getUser());
    setReady(true);
  }, [isLoginPage, pathname, router]);

  // Login page renders standalone (no sidebar/header).
  if (isLoginPage) return <>{children}</>;

  // Brief gate while we check the session client-side.
  if (!ready) {
    return (
      <div className="flex h-screen w-full items-center justify-center bg-gray-50">
        <Loader2 className="w-8 h-8 animate-spin text-gray-400" />
      </div>
    );
  }

  const pageTitle = TITLES[pathname] ?? "Overview";
  const initial = (user?.name || "A").charAt(0).toUpperCase();

  return (
    <div className="flex h-screen overflow-hidden text-gray-900">
      <Sidebar />
      <main className="flex-1 flex flex-col h-screen overflow-hidden bg-gray-50/50">
        <header className="h-20 bg-white/80 backdrop-blur-md border-b border-gray-200 flex items-center justify-between px-8 sticky top-0 z-10 shadow-sm">
          <div className="flex items-center md:hidden">
            <h1 className="text-xl font-bold text-gray-800">Shadab Super Store</h1>
          </div>
          <div className="hidden md:flex">
            <p className="text-sm text-gray-500 font-medium">
              Overview / <span className="text-gray-900 font-semibold">{pageTitle}</span>
            </p>
          </div>
          <div className="flex items-center space-x-6">
            <button className="relative p-2 text-gray-400 hover:text-gray-600 transition-colors">
              <Bell className="w-6 h-6" />
              <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-red-500 rounded-full border-2 border-white"></span>
            </button>
            <div className="flex items-center pl-6 border-l border-gray-200">
              <div className="w-10 h-10 rounded-full bg-gradient-to-r from-gray-700 to-gray-900 flex items-center justify-center text-white font-bold shadow-md">
                {initial}
              </div>
              <div className="ml-3 hidden lg:block">
                <p className="text-sm font-semibold text-gray-700 leading-tight">
                  {user?.name || "Admin"}
                </p>
                <p className="text-xs text-gray-500 font-medium">Store Owner</p>
              </div>
            </div>
          </div>
        </header>

        <div className="flex-1 overflow-y-auto p-8">
          <div className="max-w-7xl mx-auto">{children}</div>
        </div>
      </main>
    </div>
  );
}
