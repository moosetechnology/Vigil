package org.moosetechnology.vigil;

import com.thoughtworks.xstream.converters.ConverterLookup;
import com.thoughtworks.xstream.core.ReferenceByIdMarshaller;
import com.thoughtworks.xstream.io.HierarchicalStreamWriter;
import com.thoughtworks.xstream.mapper.Mapper;
import java.util.Map;
import java.util.WeakHashMap;

/**
 * Custom XStream marshaller that adds unique Object IDs (OID) to serialized objects. OIDs are
 * distinct from IDs added by the {@link ReferenceByIdMarshaller} superclass. They allow tracking
 * object identities across multiple serializations.
 */
public class ObjectIdMarshaller extends ReferenceByIdMarshaller {

  public ObjectIdMarshaller(
      HierarchicalStreamWriter writer, ConverterLookup converterLookup, Mapper mapper) {
    super(writer, converterLookup, mapper);
  }

  protected static final Map<Object, Long> objectIDs = new WeakHashMap<>();
  protected static long counter = 1L;

  protected static long getId(Object obj) {
    if (obj == null) return 0L;
    Long id = objectIDs.get(obj);
    if (id == null) {
      id = counter++;
      objectIDs.put(obj, id);
    }
    return id;
  }

  protected boolean isSimple(Class<?> clazz) {
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
