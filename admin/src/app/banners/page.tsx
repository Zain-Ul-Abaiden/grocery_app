"use client";

import { useState, useEffect } from "react";

type Banner = {
  id: number;
  image_url: string;
  is_active: boolean;
};

export default function BannersPage() {
  const [banners, setBanners] = useState<Banner[]>([]);
  const [imageUrl, setImageUrl] = useState("");

  useEffect(() => {
    fetch("http://localhost:8000/api/v1/banners")
      .then(res => res.json())
      .then(data => setBanners(data))
      .catch(err => console.error(err));
  }, []);

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    const res = await fetch("http://localhost:8000/api/v1/banners", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ image_url: imageUrl, is_active: true })
    });
    if (res.ok) {
      const newBanner = await res.json();
      setBanners([...banners, newBanner]);
      setImageUrl("");
    }
  };

  const handleDelete = async (id: number) => {
    if (!confirm("Are you sure?")) return;
    const res = await fetch(`http://localhost:8000/api/v1/banners/${id}`, {
      method: "DELETE"
    });
    if (res.ok) {
      setBanners(banners.filter(b => b.id !== id));
    }
  };

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Home Banners</h1>

      <form onSubmit={handleAdd} className="bg-white p-6 rounded-lg shadow border mb-6 flex gap-4 items-end">
        <div className="flex-1">
          <label className="block text-sm font-medium mb-1">Banner Image URL</label>
          <input 
            required
            type="text" 
            value={imageUrl}
            onChange={e => setImageUrl(e.target.value)}
            className="w-full border rounded p-2" 
            placeholder="https://..." 
          />
        </div>
        <button type="submit" className="bg-black text-white px-6 py-2 rounded font-medium h-10">Add Banner</button>
      </form>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {banners.map((banner) => (
          <div key={banner.id} className="bg-white rounded-lg shadow border overflow-hidden relative group">
            <img src={banner.image_url} alt="Banner" className="w-full h-40 object-cover" />
            <button 
              onClick={() => handleDelete(banner.id)}
              className="absolute top-2 right-2 bg-red-600 text-white p-2 rounded opacity-0 group-hover:opacity-100 transition-opacity"
            >
              Delete
            </button>
          </div>
        ))}
        {banners.length === 0 && (
          <p className="text-gray-500">No banners added yet.</p>
        )}
      </div>
    </div>
  );
}
