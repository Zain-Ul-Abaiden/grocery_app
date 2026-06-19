"use client";

import { Fragment, useState, useEffect, useCallback } from "react";
import { Loader2, ChevronDown, RefreshCw } from "lucide-react";
import { api, ApiError } from "@/lib/api";

type OrderItem = {
  id: number;
  product_name: string;
  product_unit: string;
  quantity: number;
  price_at_purchase: number;
  subtotal: number;
};

type Order = {
  id: string;
  user_id: string | null;
  total_price: number;
  status: string;
  payment_method: string;
  delivery_address: string;
  contact_phone: string;
  created_at: string;
  items: OrderItem[];
};

const STATUSES = [
  "pending",
  "confirmed",
  "out_for_delivery",
  "delivered",
  "cancelled",
];

const statusColor = (status: string) => {
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

export default function OrdersPage() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [filter, setFilter] = useState("");
  const [expanded, setExpanded] = useState<string | null>(null);
  const [updatingId, setUpdatingId] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const path = filter ? `/admin/orders?status=${filter}` : "/admin/orders";
      setOrders(await api.get<Order[]>(path));
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Failed to load orders");
    } finally {
      setLoading(false);
    }
  }, [filter]);

  useEffect(() => {
    load();
  }, [load]);

  const changeStatus = async (orderId: string, status: string) => {
    setUpdatingId(orderId);
    try {
      const updated = await api.put<Order>(`/admin/orders/${orderId}/status`, {
        status,
      });
      setOrders((prev) =>
        prev.map((o) => (o.id === orderId ? { ...o, status: updated.status } : o)),
      );
    } catch (err) {
      alert(err instanceof ApiError ? err.message : "Update failed");
    } finally {
      setUpdatingId(null);
    }
  };

  return (
    <div>
      <div className="flex flex-wrap justify-between items-center gap-3 mb-6">
        <h1 className="text-2xl font-bold">Orders Management</h1>
        <div className="flex items-center gap-2">
          <select
            value={filter}
            onChange={(e) => setFilter(e.target.value)}
            className="border border-gray-300 rounded-lg p-2 text-sm text-gray-900 bg-white focus:ring-2 focus:ring-[#2F6B1A] outline-none"
          >
            <option value="">All statuses</option>
            {STATUSES.map((s) => (
              <option key={s} value={s}>
                {s.replace(/_/g, " ")}
              </option>
            ))}
          </select>
          <button
            onClick={load}
            className="p-2 border border-gray-300 rounded-lg text-gray-600 hover:bg-gray-50"
            title="Refresh"
          >
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-xl px-4 py-3 mb-4">
          {error}
        </div>
      )}

      <div className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
        {loading ? (
          <div className="flex items-center justify-center py-16">
            <Loader2 className="w-7 h-7 animate-spin text-gray-400" />
          </div>
        ) : (
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Order
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Customer
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Total
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Update Status
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {orders.map((order) => (
                <Fragment key={order.id}>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 text-sm font-medium text-gray-900">
                      <button
                        onClick={() =>
                          setExpanded(expanded === order.id ? null : order.id)
                        }
                        className="flex items-center gap-1.5 hover:text-[#2F6B1A]"
                      >
                        <ChevronDown
                          className={`w-4 h-4 transition-transform ${expanded === order.id ? "rotate-180" : ""}`}
                        />
                        #{order.id.slice(0, 8)}
                      </button>
                      <p className="text-xs text-gray-400 ml-5.5 mt-0.5">
                        {new Date(order.created_at).toLocaleString()}
                      </p>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-600">
                      <p className="font-medium text-gray-800">
                        {order.contact_phone}
                      </p>
                      <p className="text-xs text-gray-400 max-w-[220px] truncate">
                        {order.delivery_address}
                      </p>
                    </td>
                    <td className="px-6 py-4 text-sm font-semibold text-gray-900">
                      Rs. {order.total_price.toLocaleString()}
                    </td>
                    <td className="px-6 py-4">
                      <span
                        className={`px-2.5 inline-flex text-xs leading-5 font-semibold rounded-full ${statusColor(order.status)}`}
                      >
                        {order.status.replace(/_/g, " ")}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <div className="inline-flex items-center gap-2">
                        {updatingId === order.id && (
                          <Loader2 className="w-4 h-4 animate-spin text-gray-400" />
                        )}
                        <select
                          value={order.status}
                          onChange={(e) =>
                            changeStatus(order.id, e.target.value)
                          }
                          disabled={updatingId === order.id}
                          className="border border-gray-300 rounded-lg p-1.5 text-sm text-gray-900 bg-white focus:ring-2 focus:ring-[#2F6B1A] outline-none"
                        >
                          {STATUSES.map((s) => (
                            <option key={s} value={s}>
                              {s.replace(/_/g, " ")}
                            </option>
                          ))}
                        </select>
                      </div>
                    </td>
                  </tr>
                  {expanded === order.id && (
                    <tr className="bg-gray-50/60">
                      <td colSpan={5} className="px-6 py-4">
                        <div className="text-sm">
                          <p className="font-semibold text-gray-700 mb-2">
                            Order Items
                          </p>
                          <div className="space-y-1.5">
                            {order.items.map((it) => (
                              <div
                                key={it.id}
                                className="flex justify-between text-gray-600 border-b border-gray-100 pb-1.5"
                              >
                                <span>
                                  {it.product_name}{" "}
                                  <span className="text-gray-400">
                                    ({it.product_unit}) × {it.quantity}
                                  </span>
                                </span>
                                <span className="font-medium text-gray-800">
                                  Rs. {it.subtotal.toLocaleString()}
                                </span>
                              </div>
                            ))}
                          </div>
                          <div className="flex justify-between mt-3 text-gray-900 font-bold">
                            <span>Total ({order.payment_method})</span>
                            <span>Rs. {order.total_price.toLocaleString()}</span>
                          </div>
                        </div>
                      </td>
                    </tr>
                  )}
                </Fragment>
              ))}
              {orders.length === 0 && (
                <tr>
                  <td
                    colSpan={5}
                    className="px-6 py-8 text-center text-sm text-gray-500"
                  >
                    No orders found.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
