CREATE MIGRATION m15ryf5rcygwiojnbqxjpoexxmrpguzv2454ecz7txqz7yxzcodhua
    ONTO m1lucs2xlcjehdy6iiuz444tibpj3knro5geas77ng5vhxhnovfosa
{
  ALTER TYPE default::Primitive {
      CREATE PROPERTY estimatedTime -> std::float32 {
          CREATE CONSTRAINT std::max_value((365 * 24));
          CREATE CONSTRAINT std::min_value(0);
      };
      CREATE PROPERTY targetDate -> std::datetime;
  };
};
