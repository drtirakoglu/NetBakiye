-- Faz 2: Türkiye Modülü Updates
-- 1. Add interest rate to accounts (for KMH and CC interest)
ALTER TABLE public.accounts 
ADD COLUMN IF NOT EXISTS interest_rate DECIMAL DEFAULT 0.0;

-- 2. Add installment fields to transactions
ALTER TABLE public.transactions 
ADD COLUMN IF NOT EXISTS total_installments INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS current_installment INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS parent_transaction_id UUID REFERENCES public.transactions(id) ON DELETE CASCADE;

-- 3. Add monthly interest field to budgets to track projected costs
ALTER TABLE public.budgets
ADD COLUMN IF NOT EXISTS projected_interest DECIMAL DEFAULT 0.0;

-- 4. Enable RLS for the new parent_transaction_id relation
-- (Automatically covered by existing RLS since it's on the transactions table)

COMMENT ON COLUMN public.accounts.interest_rate IS 'Aylık akdi faiz oranı (KMH veya Kredi Kartı için)';
COMMENT ON COLUMN public.transactions.total_installments IS 'Toplam taksit sayısı (Peşin ise 1)';
COMMENT ON COLUMN public.transactions.current_installment IS 'Mevcut taksit sırası';
COMMENT ON COLUMN public.transactions.parent_transaction_id IS 'Taksitli harcamanın ana (ilk) kaydı';
