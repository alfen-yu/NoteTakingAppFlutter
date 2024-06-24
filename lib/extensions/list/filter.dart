// an extension function named Filter<T> on our Stream<T> 
extension Filter<T> on Stream<List<T>> {
  // filters a stream of list of some data, and the where clause gets that something exactly 
  Stream<List<T>> filter(bool Function(T) where) => map((items) => items.where(where).toList()); 
}