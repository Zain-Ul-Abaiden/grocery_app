"use client";

import { useState, useEffect } from "react";

type OrderItem = {
  id: number;
  product_name: string;
  quantity: number;
  subtotal: number;
};

type Order = {
  id: string;
  user_id: string;
  total_price: number;
  status: string;
  payment_method: string;
  delivery_address: string;
  contact_phone: string;
  created_at: string;
  items: OrderItem[];
};

export default function OrdersPage() {
  const [orders, setOrders] = useState<Order[]>([]);

  // Since we don't have a specific GET /orders for admin yet, 
  // we are mocking it for the MVP dashboard.
  // In a real app, you would fetch from /api/v1/admin/orders
  useEffect(() => {
    // Mock data for Admin Panel UI testing
    setOrders([
      {
        id: "ORD-1234",
        user_id: "usr_1",
        total_price: 1540,
        status: "pending",
        payment_method: "Bank Transfer",
        delivery_address: "House 12, Street 4, Lahore",
        contact_phone: "03001234567",
        created_at: new Date().toISOString(),
        items: [
          { id: 1, product_name: "Fresh Potato", quantity: 2, subtotal: 100 },
          { id: 2, product_name: "Sunsilk Shampoo", quantity: 1, subtotal: 1440 }
        ]
      }
    ]);
  }, []);

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending': return 'bg-yellow-100 text-yellow-800';
      case 'confirmed': return 'bg-blue-100 text-blue-800';
      case 'out_for_delivery': return 'bg-purple-100 text-purple-800';
      case 'delivered': return 'bg-green-100 text-green-800';
      case 'cancelled': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Orders Management</h1>

      <div className="bg-white rounded-lg shadow border overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Order ID</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Customer</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total Amount</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
              <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Action</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {orders.map((order) => (
              <tr key={order.id}>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{order.id}</td>
                <td className="px-6 py-4 text-sm text-gray-500">
                  <p>{order.contact_phone}</p>
                  <p className="text-xs">{order.delivery_address}</p>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">Rs. {order.total_price}</td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${getStatusColor(order.status)}`}>
                    {order.status}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <button className="text-indigo-600 hover:text-indigo-900">View / Update</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
