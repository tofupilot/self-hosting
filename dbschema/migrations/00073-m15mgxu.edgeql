CREATE MIGRATION m15mgxul2c75lix6ihwwdd3vjxmygmfaeqibw76khrendcujhoh44q
    ONTO m15ryf5rcygwiojnbqxjpoexxmrpguzv2454ecz7txqz7yxzcodhua
{
  ALTER TYPE default::Primitive {
      ALTER PROPERTY estimatedTime {
          CREATE CONSTRAINT std::min_ex_value(0);
      };
  };
  ALTER TYPE default::Primitive {
      ALTER PROPERTY estimatedTime {
          DROP CONSTRAINT std::min_value(0);
      };
  };
};
