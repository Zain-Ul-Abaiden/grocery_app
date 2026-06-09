"use client";

import { useEffect, useState } from "react";

export default function Dashboard() {
  const [stats, setStats] = useState({
    totalOrders: 0,
    pendingOrders: 0,
    totalRevenue: 0,
    totalProducts: 0
  });

  useEffect(() => {
    // In a real app, you would fetch these from the backend API.
    // fetch('/api/v1/admin/dashboard').then(res => res.json()).then(setStats);
    
    // Stubbing for MVP
    setStats({
      totalOrders: 145,
      pendingOrders: 12,
      totalRevenue: 54300,
      totalProducts: 56
    });
  }, []);

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Dashboard Overview</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {/* Stat Cards */}
        <div className="bg-white p-6 rounded-lg shadow border">
          <h3 className="text-gray-500 text-sm font-medium">Total Orders</h3>
          <p className="text-3xl font-bold mt-2">{stats.totalOrders}</p>
        </div>
        
        <div className="bg-white p-6 rounded-lg shadow border">
          <h3 className="text-gray-500 text-sm font-medium">Pending Orders</h3>
          <p className="text-3xl font-bold mt-2 text-yellow-600">{stats.pendingOrders}</p>
        </div>
        
        <div className="bg-white p-6 rounded-lg shadow border">
          <h3 className="text-gray-500 text-sm font-medium">Total Revenue</h3>
          <p className="text-3xl font-bold mt-2 text-green-600">Rs. {stats.totalRevenue.toLocaleString()}</p>
        </div>
        
        <div className="bg-white p-6 rounded-lg shadow border">
          <h3 className="text-gray-500 text-sm font-medium">Total Products</h3>
          <p className="text-3xl font-bold mt-2">{stats.totalProducts}</p>
        </div>
      </div>
      
      <div className="mt-8 bg-white p-6 rounded-lg shadow border">
        <h2 className="text-lg font-bold mb-4">Recent Orders</h2>
        <p className="text-gray-500">A quick view of the latest orders will appear here.</p>
        {/* We will add a simple table here later if needed, or they can just use the Orders tab */}
      </div>
    </div>
  );
}
