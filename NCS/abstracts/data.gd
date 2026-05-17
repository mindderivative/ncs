@abstract class_name Data extends Resource

@warning_ignore("unused_signal")
signal data_changed

## Returns the [ResourceUID] string for this resource's file path.
func get_data_uid() -> String:
    return ResourceUID.id_to_text(ResourceLoader.get_resource_uid(self.resource_path))
