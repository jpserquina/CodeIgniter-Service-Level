<?php namespace Acme\Repositories\Homestead;

interface CustomersRepositoryInterface {
    public function getAll();
    public function getById($id);
}
