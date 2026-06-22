"use client";

import { useState, useEffect, useCallback } from "react";
import { Loader2, Pencil, Trash2, Plus } from "lucide-react";
import { api, ApiError } from "@/lib/api";

type Product = {
  id: string;
  category_id: number;
  name: string;
  description?: string;
  price: number;
  discount_price?: number | null;
  unit: string;
  stock: number;
  image_url: string;
  is_available: boolean;
  is_featured: boolean;
};

type Category = { id: number; name: string };

const EMPTY_FORM = {
  name: "",
  description: "",
  price: "",
  discount_price: "",
  unit: "1 kg",
  stock: "",
  category_id: "",
  image_url: "",
  is_available: true,
  is_featured: false,
};

export default function ProductsPage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const [showForm, setShowForm] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [form, setForm] = useState(EMPTY_FORM);
  const [saving, setSaving] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const [prods, cats] = await Promise.all([
        api.get<Product[]>("/admin/products"),
        api.get<Category[]>("/categories"),
      ]);
      setProducts(prods);
      setCategories(cats);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Failed to load products");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const openAdd = () => {
    setEditingId(null);
    setForm({ ...EMPTY_FORM, category_id: categories[0]?.id.toString() ?? "" });
    setShowForm(true);
  };

  const openEdit = (p: Product) => {
    setEditingId(p.id);
    setForm({
      name: p.name,
      description: p.description ?? "",
      price: p.price.toString(),
      discount_price: p.discount_price != null ? p.discount_price.toString() : "",
      unit: p.unit,
      stock: p.stock.toString(),
      category_id: p.category_id.toString(),
      image_url: p.image_url ?? "",
      is_available: p.is_available,
      is_featured: p.is_featured ?? false,
    });
    setShowForm(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setError("");
    const payload = {
      name: form.name,
      description: form.description || null,
      price: parseFloat(form.price),
      discount_price: form.discount_price ? parseFloat(form.discount_price) : null,
      unit: form.unit,
      stock: parseInt(form.stock || "0"),
      category_id: parseInt(form.category_id),
      image_url: form.image_url || null,
      is_available: form.is_available,
      is_featured: form.is_featured,
    };
    try {
      if (editingId) {
        await api.put<Product>(`/products/${editingId}`, payload);
      } else {
        await api.post<Product>("/products", payload);
      }
      setShowForm(false);
      setForm(EMPTY_FORM);
      setEditingId(null);
      await load();
    } catch (err) {
      setError(
        err instanceof ApiError ? err.message : "Failed to save product",
      );
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Delete this product permanently?")) return;
    try {
      await api.del(`/products/${id}`);
      setProducts((prev) => prev.filter((p) => p.id !== id));
    } catch (err) {
      alert(err instanceof ApiError ? err.message : "Delete failed");
    }
  };

  const inputCls =
    "w-full border border-gray-300 rounded-lg p-2.5 text-gray-900 bg-white focus:ring-2 focus:ring-[#2F6B1A] outline-none";

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">Products</h1>
          <p className="text-gray-500 text-sm mt-0.5">
            {products.length} item{products.length === 1 ? "" : "s"} in catalog
          </p>
        </div>
        <button
          onClick={showForm ? () => setShowForm(false) : openAdd}
          className="bg-gray-900 text-white px-4 py-2 rounded-lg font-medium shadow-sm hover:bg-gray-800 transition-colors flex items-center gap-2"
        >
          {showForm ? (
            "Cancel"
          ) : (
            <>
              <Plus className="w-4 h-4" /> Add Product
            </>
          )}
        </button>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-xl px-4 py-3 mb-4">
          {error}
        </div>
      )}

      {showForm && (
        <form
          onSubmit={handleSubmit}
          className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 mb-6 grid grid-cols-1 md:grid-cols-2 gap-4"
        >
          <h2 className="md:col-span-2 text-lg font-bold text-gray-900">
            {editingId ? "Edit Product" : "New Product"}
          </h2>
          <Field label="Product Name">
            <input
              required
              type="text"
              value={form.name}
              onChange={(e) => setForm({ ...form, name: e.target.value })}
              className={inputCls}
              placeholder="e.g. Dalda Cooking Oil 1x5"
            />
          </Field>
          <Field label="Description">
            <input
              type="text"
              value={form.description}
              onChange={(e) => setForm({ ...form, description: e.target.value })}
              className={inputCls}
              placeholder="Short description"
            />
          </Field>
          <Field label="Price (Rs)">
            <input
              required
              type="number"
              step="0.01"
              value={form.price}
              onChange={(e) => setForm({ ...form, price: e.target.value })}
              className={inputCls}
              placeholder="2999"
            />
          </Field>
          <Field label="Discount Price (Rs) — optional">
            <input
              type="number"
              step="0.01"
              value={form.discount_price}
              onChange={(e) =>
                setForm({ ...form, discount_price: e.target.value })
              }
              className={inputCls}
              placeholder="Leave empty for no discount"
            />
          </Field>
          <div className="grid grid-cols-2 gap-4">
            <Field label="Unit">
              <input
                required
                type="text"
                value={form.unit}
                onChange={(e) => setForm({ ...form, unit: e.target.value })}
                className={inputCls}
                placeholder="1 kg / 500 gram / 12 pieces"
              />
            </Field>
            <Field label="Stock">
              <input
                required
                type="number"
                value={form.stock}
                onChange={(e) => setForm({ ...form, stock: e.target.value })}
                className={inputCls}
                placeholder="100"
              />
            </Field>
          </div>
          <Field label="Category">
            <select
              required
              value={form.category_id}
              onChange={(e) => setForm({ ...form, category_id: e.target.value })}
              className={inputCls}
            >
              <option value="" disabled>
                Select a category
              </option>
              {categories.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name}
                </option>
              ))}
            </select>
          </Field>
          <Field label="Image URL">
            <input
              type="text"
              value={form.image_url}
              onChange={(e) => setForm({ ...form, image_url: e.target.value })}
              className={inputCls}
              placeholder="https://..."
            />
          </Field>
          <label className="flex items-center gap-2 text-sm text-gray-700">
            <input
              type="checkbox"
              checked={form.is_available}
              onChange={(e) =>
                setForm({ ...form, is_available: e.target.checked })
              }
              className="w-4 h-4 accent-[#2F6B1A]"
            />
            Available for sale
          </label>
          <label className="flex items-center gap-2 text-sm text-gray-700">
            <input
              type="checkbox"
              checked={form.is_featured}
              onChange={(e) =>
                setForm({ ...form, is_featured: e.target.checked })
              }
              className="w-4 h-4 accent-[#2F6B1A]"
            />
            Featured on home
          </label>
          <div className="md:col-span-2 flex justify-end mt-2">
            <button
              type="submit"
              disabled={saving}
              className="bg-[#2F6B1A] hover:bg-[#143F17] disabled:opacity-60 text-white px-8 py-2.5 rounded-lg font-bold shadow-sm transition-colors flex items-center gap-2"
            >
              {saving && <Loader2 className="w-4 h-4 animate-spin" />}
              {editingId ? "Update Product" : "Save Product"}
            </button>
          </div>
        </form>
      )}

      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        {loading ? (
          <div className="flex items-center justify-center py-16">
            <Loader2 className="w-7 h-7 animate-spin text-gray-400" />
          </div>
        ) : (
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <Th>Image</Th>
                <Th>Name</Th>
                <Th>Price / Unit</Th>
                <Th>Stock</Th>
                <Th>Status</Th>
                <Th right>Actions</Th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-100">
              {products.map((p) => (
                <tr key={p.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-6 py-4">
                    {p.image_url ? (
                      // eslint-disable-next-line @next/next/no-img-element
                      <img
                        src={p.image_url}
                        alt={p.name}
                        className="h-12 w-12 rounded-lg object-cover border border-gray-100"
                      />
                    ) : (
                      <div className="h-12 w-12 rounded-lg bg-gray-100 border border-gray-200 flex items-center justify-center text-gray-400 text-xs">
                        No img
                      </div>
                    )}
                  </td>
                  <td className="px-6 py-4 text-sm font-semibold text-gray-900">
                    <div className="flex items-center gap-2">
                      {p.name}
                      {p.is_featured && (
                        <span className="px-2 py-0.5 rounded-full font-medium text-[10px] bg-amber-100 text-amber-800">
                          Featured
                        </span>
                      )}
                    </div>
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-600">
                    {p.discount_price != null ? (
                      <span>
                        <span className="text-green-600 font-semibold">
                          Rs. {p.discount_price}
                        </span>{" "}
                        <span className="line-through text-gray-400">
                          {p.price}
                        </span>
                      </span>
                    ) : (
                      <span>Rs. {p.price}</span>
                    )}{" "}
                    <span className="text-gray-400">/ {p.unit}</span>
                  </td>
                  <td className="px-6 py-4 text-sm">
                    <span
                      className={`px-2.5 py-1 rounded-full font-medium text-xs ${p.stock > 10 ? "bg-green-100 text-green-800" : p.stock > 0 ? "bg-yellow-100 text-yellow-800" : "bg-red-100 text-red-800"}`}
                    >
                      {p.stock} left
                    </span>
                  </td>
                  <td className="px-6 py-4 text-sm">
                    <span
                      className={`px-2.5 py-1 rounded-full font-medium text-xs ${p.is_available ? "bg-emerald-100 text-emerald-800" : "bg-gray-100 text-gray-600"}`}
                    >
                      {p.is_available ? "Live" : "Hidden"}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right text-sm font-medium">
                    <div className="flex items-center justify-end gap-2">
                      <button
                        onClick={() => openEdit(p)}
                        className="text-gray-600 hover:text-gray-900 bg-gray-50 hover:bg-gray-100 p-2 rounded-lg transition-colors"
                        title="Edit"
                      >
                        <Pencil className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => handleDelete(p.id)}
                        className="text-red-500 hover:text-red-700 bg-red-50 hover:bg-red-100 p-2 rounded-lg transition-colors"
                        title="Delete"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
              {products.length === 0 && (
                <tr>
                  <td
                    colSpan={6}
                    className="px-6 py-8 text-center text-sm text-gray-500"
                  >
                    No products found. Click &quot;Add Product&quot; to create one.
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

function Field({
  label,
  children,
}: {
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div>
      <label className="block text-sm font-medium mb-1 text-gray-700">
        {label}
      </label>
      {children}
    </div>
  );
}

function Th({
  children,
  right,
}: {
  children: React.ReactNode;
  right?: boolean;
}) {
  return (
    <th
      className={`px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider ${right ? "text-right" : "text-left"}`}
    >
      {children}
    </th>
  );
}
