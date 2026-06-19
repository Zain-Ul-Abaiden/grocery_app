"use client";

import { useState, useEffect } from "react";
import { Loader2, Trash2, Plus } from "lucide-react";
import { api, ApiError } from "@/lib/api";

type Category = {
  id: number;
  name: string;
  image_url: string;
};

export default function CategoriesPage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [isAdding, setIsAdding] = useState(false);
  const [name, setName] = useState("");
  const [imageUrl, setImageUrl] = useState("");
  const [saving, setSaving] = useState(false);

  const load = () => {
    setLoading(true);
    api
      .get<Category[]>("/categories")
      .then(setCategories)
      .catch((err) =>
        setError(err instanceof ApiError ? err.message : "Failed to load"),
      )
      .finally(() => setLoading(false));
  };

  useEffect(load, []);

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setError("");
    try {
      const cat = await api.post<Category>("/categories", {
        name,
        image_url: imageUrl || null,
      });
      setCategories((prev) => [...prev, cat]);
      setIsAdding(false);
      setName("");
      setImageUrl("");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Failed to add category");
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id: number) => {
    if (!confirm("Delete this category? Products in it may be affected.")) return;
    try {
      await api.del(`/categories/${id}`);
      setCategories((prev) => prev.filter((c) => c.id !== id));
    } catch (err) {
      alert(err instanceof ApiError ? err.message : "Delete failed");
    }
  };

  const inputCls =
    "w-full border border-gray-300 rounded-lg p-2.5 text-gray-900 bg-white focus:ring-2 focus:ring-[#2F6B1A] outline-none transition-all shadow-sm";

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Categories</h1>
        <button
          onClick={() => setIsAdding(!isAdding)}
          className="bg-gray-900 text-white px-4 py-2 rounded-lg font-medium flex items-center gap-2 hover:bg-gray-800 transition-colors"
        >
          {isAdding ? (
            "Cancel"
          ) : (
            <>
              <Plus className="w-4 h-4" /> Add Category
            </>
          )}
        </button>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-xl px-4 py-3 mb-4">
          {error}
        </div>
      )}

      {isAdding && (
        <form
          onSubmit={handleAdd}
          className="bg-white p-6 rounded-lg shadow-sm border border-gray-100 mb-6 flex flex-col gap-4"
        >
          <div>
            <label className="block text-sm font-medium mb-1 text-gray-700">
              Name
            </label>
            <input
              required
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className={inputCls}
              placeholder="e.g. Fresh Vegetables"
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1 text-gray-700">
              Image URL
            </label>
            <input
              type="text"
              value={imageUrl}
              onChange={(e) => setImageUrl(e.target.value)}
              className={inputCls}
              placeholder="https://..."
            />
          </div>
          <button
            type="submit"
            disabled={saving}
            className="bg-[#2F6B1A] hover:bg-[#143F17] disabled:opacity-60 text-white py-2.5 rounded-lg font-bold w-32 flex items-center justify-center gap-2"
          >
            {saving && <Loader2 className="w-4 h-4 animate-spin" />}
            Save
          </button>
        </form>
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
                  ID
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Image
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Name
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {categories.map((category) => (
                <tr key={category.id}>
                  <td className="px-6 py-4 text-sm text-gray-500">
                    {category.id}
                  </td>
                  <td className="px-6 py-4">
                    {category.image_url ? (
                      // eslint-disable-next-line @next/next/no-img-element
                      <img
                        src={category.image_url}
                        alt={category.name}
                        className="h-10 w-10 rounded object-cover"
                      />
                    ) : (
                      <div className="h-10 w-10 rounded bg-gray-200"></div>
                    )}
                  </td>
                  <td className="px-6 py-4 text-sm font-medium text-gray-900">
                    {category.name}
                  </td>
                  <td className="px-6 py-4 text-right text-sm font-medium">
                    <button
                      onClick={() => handleDelete(category.id)}
                      className="text-red-500 hover:text-red-700 bg-red-50 hover:bg-red-100 p-2 rounded-lg transition-colors inline-flex"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}
              {categories.length === 0 && (
                <tr>
                  <td
                    colSpan={4}
                    className="px-6 py-4 text-center text-sm text-gray-500"
                  >
                    No categories found.
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
