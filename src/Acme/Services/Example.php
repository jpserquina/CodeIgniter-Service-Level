<?php namespace Acme\Services;

use Acme\Services\Cookie;
use Acme\Repositories\Homestead\CustomersRepositoryInterface as Customer;

/*
 * This is obviously a highly oversimplified example. All we are doing here
 * is returning something from the Database Repository but in the real
 * world, this is where your logic goes.
 */
class Example
{
    protected $customer;

    public function __construct(Customer $customer)
    {
        $this->customer = $customer;
    }

    public function getCustomer($id)
    {

        $customer = $this->customer->getById($id);

        return $customer;
    }

}
