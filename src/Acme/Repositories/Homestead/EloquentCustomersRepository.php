<?php namespace Acme\Repositories\Homestead;

use Acme\Repositories\EloquentRepository;
use Acme\Models\Eloquent\Homestead\Customers;

class EloquentCustomersRepository extends EloquentRepository implements CustomersRepositoryInterface
{
    protected $model;

    public function __construct(Customers $model)
    {
        $this->model = $model;
    }

    /*-------------------------------------------------------------------------
    | Override below or supplement any methods from the interface
    |--------------------------------------------------------------------------
    */

}
