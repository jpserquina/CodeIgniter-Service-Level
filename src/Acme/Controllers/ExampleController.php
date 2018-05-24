<?php namespace Acme\Controllers;

use Acme\Services\Example;

class ExampleController
{
    public $example;

    public function __construct(Example $example)
    {
        $this->example = $example;
    }

    public function index($customerId)
    {
        return $this->example->getCustomer($customerId);
    }
}
