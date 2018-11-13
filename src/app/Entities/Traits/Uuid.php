<?php

namespace App\Entities\Traits;

use Webpatser\Uuid\Uuid as UuidGenerator;

trait Uuid {

    /**
     *  Setup model event hooks
     */
    public static function boot()
    {
        parent::boot();
        self::creating(function ($model) {

           if (is_string($model->id)) {
               return;
           }

            $model->id = (string) UuidGenerator::generate(4);
        });
    }
}
