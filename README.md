# ![s_s_aurora logo](https://user-images.githubusercontent.com/52039582/61178138-71823100-a621-11e9-92cd-5afe46a76434.png)

Aurora is fast seeder of 'Ruby on Rails' that uses .yml
Currently only mysql supported

## Features

### Easy to use
Aurora can be used only for simple configuration file settings  
You don't have to write a program for seeder

### Fast speed
If it is the following table, 10,000 records can regist in 0.46s on average  
Also, If you enable 'optimize option', 10,000 records can regist in 0.25s on average

|Field|Type|NULL|
|:---|:---|:---|
|id|bigint(20)| NO|
|name|varchar(255)|YES|
|created_at|datetime|NO|
|updated_at|datetime|NO|

## Getting started
Add this line to your application's Gemfile:

```ruby
gem 'k_aurora'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install k_aurora
```

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Usage
Introduce how to execute and write configuration file.   
If you want to know more information file settings,  please refer to the test

### Extecute
After write configuration file, execute the following source code in seed.rb of Ruby on Rails

```
Aurora.execute(ConfigrationFilePath...)
```
### Configration file

Introduce how to write configuration file

#### Definition for explanation  
Table name below is 'prefs' and model name is 'Pref'

|Field|Type|NULL|
|:---|:---|:---|
|id|bigint(20)| NO|
|name|varchar(255)|YES|
|created_at|datetime|NO|
|updated_at|datetime|NO|


Table name below is 'members' and model name is 'Member'

|Field|Type|NULL|
|:---|:---|:---|
|id|bigint(20)| NO|
|name|varchar(255)|YES|
|remarks|text|YES|
|birthday|date|YES|
|pref_id|bigint(20)|YES|
|created_at|datetime|NO|
|updated_at|datetime|NO|


#### Default data
If there is no column definition, prepared data is registerd three times  
id column is basically registerd by autoincrement

```
Default:
  Pref: 
    loop: 3
```


In the following source code, id, created_at, updated_at will be registerd with the prepared data  

```
Default:
  Pref: 
    loop: 3
    col:
      name: "Hokkaido"
```

#### Array
Array data is registerd one by one

```
Default:
  Pref: 
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]
```

#### Maked data
Registration is possible using registerd data

```
Default:
  Pref: 
    loop: 2
    col:
      name: ["Hokkaido", "Aomori"]
  Member:
    loop: 2
    col:
      name: <maked[:Pref][:name]>
      pref_id: F|Pref
```

```
Default:
  Pref: 
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]
  Member: 
    loop: 3
    col:
      name: ["Tarou", "Jirou", "Saburou"]
      remarks: <maked[:Member][:name]>
      pref_id: F|Pref

```

#### Foreign key
What a means is ' F| ' foreign key

In the following source code, Foreign key of prefectures is registerd

```
Default:
  Pref: 
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]
  Member:
    loop: 3
    col:
      pref_id: F|Pref
```

#### Expression expansion
What a means is '< >' expression expansion  
You can run ruby code in '< >'

```
Default:
  Pref: 
    loop: 3
    col:
      name: <["Hokkaido", "Aomori", "Iwate"]>
      created_at: <Date.parse('1997/02/05')>
```

#### Add method
You can add method and use it in aurora

```
Default:
  Pref: 
    loop: 3
    col:
      name: <pref_name>
```

Prepare the following ruby file
```
def pref_name
  ["Hokkaido", "Aomori", "Iwate"]
end
```
and execute the following source code in seed.rb of Ruby on Rails

```
Aurora.import(MethodFilePath...)
Aurora.execute(ConfigrationFilePath...)
```


#### Use multiple blocks

Registration is possible using two blocks

```
Default:
  Pref: 
    loop: 3
Default2:
  Pref:
    loop: 3
```

and, You can change the name of the block

```
Hoge:
  Pref: 
    loop: 3
Fuga:
  Pref:
    loop: 3
```


#### Random
Shuffle seed data when regist

```
Default:
  Pref: 
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]
    option:
      name: ["random"]
```

The following results change from run to run

```
["Aomori", "Iwate", "Iwate"]
```

#### Add_id
Add individual number to seed data of String type

```
Default:
  Pref: 
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]
    option:
      name: ["add_id"]
```

```
["Hokkaido_0", "Aomori"_1, "Iwate_2"]
```

#### Combine serveral options
Combination of options is possible

```
Default:
  Pref: 
    loop: 3
    col:
      name: ["Hokkaido", "Aomori", "Iwate"]
    option:
      name: ["add_id", "random"]
```

The following results change from run to run

```
["Hokkaido_0", "Iwate_1", "Hokkaido_2"]
```

#### Validation

Run validation when regist

```
Default:
  Pref: 
    loop: 3
    validate: true
```

#### Autoincrement

You can disable the autoincrement setting

If you disable the setting, you can register id data prepared by myself

```
Default:
  Pref: 
    loop: 3
    autoincrement: false
    col:
      id: [100, 101, 102]
```

#### Optimize

If you enable 'optimize', Aurora Run a fast query builder, but instead of disabling validation

```
Default:
  Pref: 
    loop: 3
    optimaize: true
```
