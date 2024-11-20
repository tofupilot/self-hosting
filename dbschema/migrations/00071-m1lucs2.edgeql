CREATE MIGRATION m1lucs2xlcjehdy6iiuz444tibpj3knro5geas77ng5vhxhnovfosa
    ONTO m1y5aosuqqorsx2yegokqvvbcirjmqs7lma7xhgyhpc6t23gxy35eq
{
  ALTER TYPE default::Status {
      ALTER PROPERTY name {
          CREATE CONSTRAINT std::min_len_value(1);
      };
  };
};
