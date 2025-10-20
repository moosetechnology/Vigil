package fr.vigil;

import com.thoughtworks.xstream.converters.ConverterLookup;
import com.thoughtworks.xstream.core.ReferenceByIdMarshaller;
import com.thoughtworks.xstream.io.HierarchicalStreamWriter;
import com.thoughtworks.xstream.mapper.Mapper;
import java.util.Map;
import java.util.WeakHashMap;
import java.util.concurrent.atomic.AtomicInteger;

public class ObjectIdMarshaller extends ReferenceByIdMarshaller {

  public ObjectIdMarshaller(
      HierarchicalStreamWriter writer, ConverterLookup converterLookup, Mapper mapper) {
    super(writer, converterLookup, mapper);
  }

  protected static final Map<Object, Integer> ids = new WeakHashMap<>();
  protected static final AtomicInteger counter = new AtomicInteger(1);

  protected static int getId(Object obj) {
    if (obj == null) return 0;
    Integer id = ids.get(obj);
    if (id == null) {
      id = counter.getAndIncrement();
      ids.put(obj, id);
    }
    return id;
  }

  private boolean isSimple(Class<?> clazz) {
    return clazz.isPrimitive()
        || clazz == String.class
        || clazz == Boolean.class
        || clazz == Character.class
        || Number.class.isAssignableFrom(clazz);
  }

  @Override
  public void convertAnother(Object item) {
    if (item != null && !isSimple(item.getClass())) {
      writer.addAttribute("oid", String.valueOf(getId(item)));
    }
    super.convertAnother(item);
  }
}
