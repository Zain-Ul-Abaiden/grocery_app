"use client";

import { useState, useEffect } from "react";
import { Loader2, Trash2 } from "lucide-react";
import { api, ApiError } from "@/lib/api";

type Banner = {
  id: number;
  image_url: string;
  is_active: boolean;
};

export default function BannersPage() {
  const [banners, setBanners] = useState<Banner[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [imageUrl, setImageUrl] = useState("");
  const [saving, setSaving] = useState(false);

  const load = () => {
    setLoading(true);
    api
      .get<Banner[]>("/banners")
      .then(setBanners)
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
      const banner = await api.post<Banner>("/banners", {
        image_url: imageUrl,
        is_active: true,
      });
      setBanners((prev) => [...prev, banner]);
      setImageUrl("");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Failed to add banner");
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id: number) => {
    if (!confirm("Delete this banner?")) return;
    try {
      await api.del(`/banners/${id}`);
      setBanners((prev) => prev.filter((b) => b.id !== id));
    } catch (err) {
      alert(err instanceof ApiError ? err.message : "Delete failed");
    }
  };

  return (
    <div>
      <h1 className="text-2xl font-bold mb-2">Home Banners</h1>
      <p className="text-gray-500 text-sm mb-6">
        These appear in the carousel at the top of the customer app home screen.
      </p>

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-xl px-4 py-3 mb-4">
          {error}
        </div>
      )}

      <form
        onSubmit={handleAdd}
        className="bg-white p-6 rounded-lg shadow-sm border border-gray-100 mb-6 flex gap-4 items-end"
      >
        <div className="flex-1">
          <label className="block text-sm font-medium mb-1 text-gray-700">
            Banner Image URL
          </label>
          <input
            required
            type="text"
            value={imageUrl}
            onChange={(e) => setImageUrl(e.target.value)}
            className="w-full border border-gray-300 rounded-lg p-2.5 text-gray-900 bg-white focus:ring-2 focus:ring-yellow-400 outline-none transition-all shadow-sm"
            placeholder="https://..."
          />
        </div>
        <button
          type="submit"
          disabled={saving}
          className="bg-gray-900 hover:bg-gray-800 disabled:opacity-60 text-white px-6 py-2.5 rounded-lg font-medium flex items-center gap-2"
        >
          {saving && <Loader2 className="w-4 h-4 animate-spin" />}
          Add Banner
        </button>
      </form>

      {loading ? (
        <div className="flex items-center justify-center py-16">
          <Loader2 className="w-7 h-7 animate-spin text-gray-400" />
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {banners.map((banner) => (
            <div
              key={banner.id}
              className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden relative group"
            >
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img
                src={banner.image_url}
                alt="Banner"
                className="w-full h-40 object-cover"
              />
              <button
                onClick={() => handleDelete(banner.id)}
                className="absolute top-2 right-2 bg-red-600 text-white p-2 rounded-lg opacity-0 group-hover:opacity-100 transition-opacity"
              >
                <Trash2 className="w-4 h-4" />
              </button>
            </div>
          ))}
          {banners.length === 0 && (
            <p className="text-gray-500">No banners added yet.</p>
          )}
        </div>
      )}
    </div>
  );
}
