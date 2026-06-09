"use client";

import { useState, useEffect } from "react";

type Category = {
  id: number;
  name: string;
  image_url: string;
};

export default function CategoriesPage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [isAdding, setIsAdding] = useState(false);
  const [name, setName] = useState("");
  const [imageUrl, setImageUrl] = useState("");

  useEffect(() => {
    fetch("http://localhost:8000/api/v1/categories")
      .then(res => res.json())
      .then(data => setCategories(data))
      .catch(err => console.error(err));
  }, []);

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    // Assuming auth is handled or bypassed for now locally
    const res = await fetch("http://localhost:8000/api/v1/categories", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name, image_url: imageUrl })
    });
    if (res.ok) {
      const newCat = await res.json();
      setCategories([...categories, newCat]);
      setIsAdding(false);
      setName("");
      setImageUrl("");
    }
  };

  const handleDelete = async (id: number) => {
    if (!confirm("Are you sure?")) return;
    const res = await fetch(`http://localhost:8000/api/v1/categories/${id}`, {
      method: "DELETE"
    });
    if (res.ok) {
      setCategories(categories.filter(c => c.id !== id));
    }
  };

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Categories</h1>
        <button 
          onClick={() => setIsAdding(!isAdding)}
          className="bg-black text-white px-4 py-2 rounded font-medium"
        >
          {isAdding ? "Cancel" : "Add Category"}
        </button>
      </div>

      {isAdding && (
        <form onSubmit={handleAdd} className="bg-white p-6 rounded-lg shadow border mb-6 flex flex-col gap-4">
          <div>
            <label className="block text-sm font-medium mb-1">Name</label>
            <input 
              required
              type="text" 
              value={name}
              onChange={e => setName(e.target.value)}
              className="w-full border rounded p-2" 
              placeholder="e.g. Fresh Vegetables" 
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Image URL</label>
            <input 
              type="text" 
              value={imageUrl}
              onChange={e => setImageUrl(e.target.value)}
              className="w-full border rounded p-2" 
              placeholder="https://..." 
            />
          </div>
          <button type="submit" className="bg-black text-white py-2 rounded font-medium w-32">Save</button>
        </form>
      )}

      <div className="bg-white rounded-lg shadow border overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Image</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
              <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {categories.map((category) => (
              <tr key={category.id}>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{category.id}</td>
                <td className="px-6 py-4 whitespace-nowrap">
                  {category.image_url ? (
                    <img src={category.image_url} alt={category.name} className="h-10 w-10 rounded object-cover" />
                  ) : (
                    <div className="h-10 w-10 rounded bg-gray-200"></div>
                  )}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{category.name}</td>
                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <button onClick={() => handleDelete(category.id)} className="text-red-600 hover:text-red-900">Delete</button>
                </td>
              </tr>
            ))}
            {categories.length === 0 && (
              <tr>
                <td colSpan={4} className="px-6 py-4 text-center text-sm text-gray-500">No categories found.</td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
