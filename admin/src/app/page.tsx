"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import {
  TrendingUp,
  Package,
  ShoppingCart,
  DollarSign,
  Clock,
  ArrowRight,
  Users,
  Loader2,
} from "lucide-react";
import { api, ApiError } from "@/lib/api";

type Stats = {
  total_revenue: number;
  total_orders: number;
  pending_orders: number;
  total_users: number;
  out_of_stock_products: number;
  total_products: number;
};

type RecentOrder = {
  id: string;
  contact_phone: string;
  delivery_address: string;
  total_price: number;
  status: string;
  created_at: string;
};

type DashboardResponse = { stats: Stats; recent_orders: RecentOrder[] };

const statusBadge = (status: string) => {
  switch (status) {
    case "pending":
      return "bg-yellow-100 text-yellow-800";
    case "confirmed":
      return "bg-blue-100 text-blue-800";
    case "out_for_delivery":
      return "bg-purple-100 text-purple-800";
    case "delivered":
      return "bg-green-100 text-green-800";
    case "cancelled":
      return "bg-red-100 text-red-800";
    default:
      return "bg-gray-100 text-gray-800";
  }
};

export default function Dashboard() {
  const [data, setData] = useState<DashboardResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    api
      .get<DashboardResponse>("/admin/dashboard")
      .then((res) => setData(res))
      .catch((err) =>
        setError(err instanceof ApiError ? err.message : "Failed to load stats"),
      )
      .finally(() => setLoading(false));
  }, []);

  const stats = data?.stats;
  const recent = data?.recent_orders ?? [];

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 tracking-tight">
            Dashboard Overview
          </h1>
          <p className="text-gray-500 mt-1">
            Here is what is happening in your store today.
          </p>
        </div>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-20">
          <Loader2 className="w-8 h-8 animate-spin text-gray-400" />
        </div>
      ) : error ? (
        <div className="bg-red-50 border border-red-200 text-red-700 rounded-xl px-5 py-4">
          {error}
        </div>
      ) : (
        <>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <StatCard
              label="Total Orders"
              value={stats!.total_orders.toString()}
              icon={<ShoppingCart className="w-5 h-5" />}
              bgIcon={<ShoppingCart className="w-16 h-16 text-blue-600" />}
              accent="bg-blue-50 text-blue-600"
              footer={`${stats!.pending_orders} pending`}
            />
            <StatCard
              label="Pending Orders"
              value={stats!.pending_orders.toString()}
              icon={<Clock className="w-5 h-5" />}
              bgIcon={<Clock className="w-16 h-16 text-yellow-600" />}
              accent="bg-yellow-50 text-yellow-600"
              footer="Needs attention"
            />
            <div className="bg-gradient-to-br from-gray-900 to-gray-800 p-6 rounded-2xl shadow-xl shadow-gray-900/20 relative overflow-hidden group">
              <div className="absolute top-0 right-0 p-4 opacity-10">
                <DollarSign className="w-16 h-16 text-white" />
              </div>
              <div className="flex items-center justify-between mb-4 relative z-10">
                <h3 className="text-gray-400 text-sm font-semibold uppercase tracking-wider">
                  Total Revenue
                </h3>
                <span className="bg-white/10 text-white p-2 rounded-lg">
                  <DollarSign className="w-5 h-5" />
                </span>
              </div>
              <p className="text-4xl font-bold text-white relative z-10">
                Rs. {stats!.total_revenue.toLocaleString()}
              </p>
              <div className="mt-4 flex items-center text-sm relative z-10">
                <span className="text-gray-400">From delivered orders</span>
              </div>
            </div>
            <StatCard
              label="Total Products"
              value={stats!.total_products.toString()}
              icon={<Package className="w-5 h-5" />}
              bgIcon={<Package className="w-16 h-16 text-purple-600" />}
              accent="bg-purple-50 text-purple-600"
              footer={`${stats!.out_of_stock_products} out of stock`}
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <SmallStat
              label="Registered Customers"
              value={stats!.total_users}
              icon={<Users className="w-5 h-5 text-emerald-600" />}
            />
            <SmallStat
              label="Out of Stock Items"
              value={stats!.out_of_stock_products}
              icon={<Package className="w-5 h-5 text-red-600" />}
            />
          </div>

          {/* Recent Orders */}
          <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
            <div className="p-6 border-b border-gray-100 flex items-center justify-between">
              <div>
                <h2 className="text-xl font-bold text-gray-900 tracking-tight">
                  Recent Orders
                </h2>
                <p className="text-gray-500 text-sm mt-1">
                  Latest transactions from your customers.
                </p>
              </div>
              <Link
                href="/orders"
                className="text-blue-600 font-medium text-sm hover:text-blue-700 flex items-center group"
              >
                View All{" "}
                <ArrowRight className="w-4 h-4 ml-1 group-hover:translate-x-1 transition-transform" />
              </Link>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-gray-50/50">
                    <th className="py-4 px-6 text-xs font-semibold text-gray-500 uppercase tracking-wider border-b border-gray-100">
                      Order ID
                    </th>
                    <th className="py-4 px-6 text-xs font-semibold text-gray-500 uppercase tracking-wider border-b border-gray-100">
                      Customer
                    </th>
                    <th className="py-4 px-6 text-xs font-semibold text-gray-500 uppercase tracking-wider border-b border-gray-100">
                      Status
                    </th>
                    <th className="py-4 px-6 text-xs font-semibold text-gray-500 uppercase tracking-wider border-b border-gray-100">
                      Total
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100">
                  {recent.map((o) => (
                    <tr key={o.id} className="hover:bg-gray-50/50 transition-colors">
                      <td className="py-4 px-6 text-sm font-medium text-gray-900">
                        #{o.id.slice(0, 8)}
                      </td>
                      <td className="py-4 px-6 text-sm text-gray-600">
                        {o.contact_phone}
                      </td>
                      <td className="py-4 px-6">
                        <span
                          className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${statusBadge(o.status)}`}
                        >
                          {o.status}
                        </span>
                      </td>
                      <td className="py-4 px-6 text-sm font-semibold text-gray-900">
                        Rs. {o.total_price.toLocaleString()}
                      </td>
                    </tr>
                  ))}
                  {recent.length === 0 && (
                    <tr>
                      <td
                        colSpan={4}
                        className="py-8 px-6 text-center text-sm text-gray-500"
                      >
                        No orders yet.
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}
    </div>
  );
}

function StatCard({
  label,
  value,
  icon,
  bgIcon,
  accent,
  footer,
}: {
  label: string;
  value: string;
  icon: React.ReactNode;
  bgIcon: React.ReactNode;
  accent: string;
  footer: string;
}) {
  return (
    <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 relative overflow-hidden group hover:shadow-md transition-shadow">
      <div className="absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity">
        {bgIcon}
      </div>
      <div className="flex items-center justify-between mb-4 relative z-10">
        <h3 className="text-gray-500 text-sm font-semibold uppercase tracking-wider">
          {label}
        </h3>
        <span className={`${accent} p-2 rounded-lg`}>{icon}</span>
      </div>
      <p className="text-4xl font-bold text-gray-900 relative z-10">{value}</p>
      <div className="mt-4 flex items-center text-sm relative z-10">
        <span className="text-gray-400">{footer}</span>
      </div>
    </div>
  );
}

function SmallStat({
  label,
  value,
  icon,
}: {
  label: string;
  value: number;
  icon: React.ReactNode;
}) {
  return (
    <div className="bg-white p-5 rounded-2xl shadow-sm border border-gray-100 flex items-center gap-4">
      <div className="w-12 h-12 rounded-xl bg-gray-50 flex items-center justify-center">
        {icon}
      </div>
      <div>
        <p className="text-2xl font-bold text-gray-900">{value}</p>
        <p className="text-sm text-gray-500">{label}</p>
      </div>
    </div>
  );
}
