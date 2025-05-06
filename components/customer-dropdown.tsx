'use client';

import { useRouter, usePathname } from 'next/navigation';
import { CustomerInfo } from '@/lib/types';

interface CustomerDropdownProps {
  customers: CustomerInfo[];
  currentCustomerId: number | null;
}

export default function CustomerDropdown({ customers, currentCustomerId }: CustomerDropdownProps) {
  const router = useRouter();
  const pathname = usePathname();

  const handleChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const customerId = e.target.value;
    
    // Create a URL object based on the current URL
    const url = new URL(window.location.href);
    
    // Update or remove the customerId parameter
    if (customerId) {
      url.searchParams.set('customerId', customerId);
    } else {
      url.searchParams.delete('customerId');
    }
    
    // Use router.push to navigate without full page reload
    router.push(url.pathname + url.search);
    
    // Force refresh to ensure data is updated
    window.location.href = url.toString();
  };

  return (
    <select 
      className="border-none outline-none bg-transparent text-sm font-medium hover:text-orange-700"
      value={currentCustomerId?.toString() || ''}
      onChange={handleChange}
    >
      <option value="">All Customers</option>
      {customers.map(customer => (
        <option key={customer.id} value={customer.id.toString()}>
          {customer.name}
        </option>
      ))}
    </select>
  );
} 