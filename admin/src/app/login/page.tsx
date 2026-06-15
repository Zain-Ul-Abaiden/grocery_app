"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { ShoppingBag, Loader2, Lock } from "lucide-react";
import { api, saveSession, ApiError, type AdminUser } from "@/lib/api";

type LoginResponse = {
  access_token: string;
  token_type: string;
  user: AdminUser;
};

export default function LoginPage() {
  const router = useRouter();
  const [phone, setPhone] = useState("+923001234567");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      const data = await api.post<LoginResponse>("/auth/login", {
        phone: phone.trim(),
        password,
      });
      if (data.user.role !== "admin") {
        setError("This account is not an administrator.");
        setLoading(false);
        return;
      }
      saveSession(data.access_token, data.user);
      router.replace("/");
    } catch (err) {
      setError(
        err instanceof ApiError ? err.message : "Login failed. Try again.",
      );
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen w-full flex items-center justify-center bg-gradient-to-br from-[#0F172A] via-[#1e293b] to-[#0F172A] p-4">
      <div className="w-full max-w-md">
        <div className="flex flex-col items-center mb-8">
          <div className="w-16 h-16 rounded-2xl bg-gradient-to-tr from-yellow-400 to-yellow-500 flex items-center justify-center shadow-lg shadow-yellow-500/30 mb-4">
            <ShoppingBag className="text-gray-900 w-8 h-8" />
          </div>
          <h1 className="text-3xl font-bold text-white tracking-tight">
Shadab Super <span className="text-yellow-400">Store</span>
          </h1>
          <p className="text-gray-400 mt-1 text-sm">Store management dashboard</p>
        </div>

        <form
          onSubmit={handleSubmit}
          className="bg-white rounded-2xl shadow-2xl p-8 space-y-5"
        >
          <div>
            <label className="block text-sm font-semibold mb-1.5 text-gray-700">
              Phone Number
            </label>
            <input
              required
              type="text"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              className="w-full border border-gray-300 rounded-xl p-3 text-gray-900 bg-white focus:ring-2 focus:ring-yellow-400 focus:border-yellow-400 outline-none transition-all"
              placeholder="+923001234567"
            />
          </div>
          <div>
            <label className="block text-sm font-semibold mb-1.5 text-gray-700">
              Password
            </label>
            <input
              required
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full border border-gray-300 rounded-xl p-3 text-gray-900 bg-white focus:ring-2 focus:ring-yellow-400 focus:border-yellow-400 outline-none transition-all"
              placeholder="••••••••"
            />
          </div>

          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-xl px-4 py-3">
              {error}
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-yellow-400 hover:bg-yellow-500 disabled:opacity-60 text-gray-900 py-3 rounded-xl font-bold shadow-sm transition-colors flex items-center justify-center gap-2"
          >
            {loading ? (
              <Loader2 className="w-5 h-5 animate-spin" />
            ) : (
              <Lock className="w-4 h-4" />
            )}
            {loading ? "Signing in..." : "Sign In"}
          </button>

          <p className="text-center text-xs text-gray-400 pt-2">
            Default admin: +923001234567 / admin123
          </p>
        </form>
      </div>
    </div>
  );
}
